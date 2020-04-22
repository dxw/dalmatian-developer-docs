class DalmatianParameterStore
  def initialize(account_id:)
    role_arn = "arn:aws:iam::#{account_id}:role/dalmatian-admin"
    role_session_name = 'dalmatian-environment-variables-gui'
    @ssm = SSM.new(role_arn: role_arn, role_session_name: 'role_session_name')
  end

  def ssm
    @ssm
  end

  def get_user_account_id
    caller_identity = sts.get_caller_identity
    caller_identity.account
  end

  def get_params_from_path(path:)
    params = ssm.get_parameters_by_path(
      path: path,
      with_decryption: true,
      recursive: false
    )
    params.each{ |p| p[:name] = File.basename(p[:name]) }
  end

  def save_params_to_path(path:, params:, key_id:)
    current_params = get_params_from_path(path: path)
    to_delete = resolve_deleted(current_params: current_params, new_params: params)
    delete_params(path: path, names: to_delete) if !to_delete.empty?
    put_params(path: path, params: params, key_id: key_id)
  end

  def resolve_deleted(current_params:, new_params:)
    current_names = current_params.map{ |p| p[:name] }
    new_names = new_params.map{ |k,p| p['name'] }
    current_names - new_names
  end

  def delete_params(path:, names:)
    names_with_path = names.map{ |name| "#{path}#{name}" }
    ssm.delete_parameters(names: names_with_path)
    wait_until_params_deleted(path: path, names: names)
  end

  def wait_until_params_deleted(path:, names:)
    # there's a slight delay with deleting params
    # this allows pausing until moving on
    deleted = 0
    while deleted == 0 do
      current_params = get_params_from_path(path: path)
      current_names = current_params.map{ |p| p[:name] }
      deleted = 1 if (current_names & names).empty?
      sleep(1)
    end
  end

  def put_params(path:, params:, key_id:)
    params.each do |k,p|
      if !p['name'].empty?
        name_with_path = "#{path}#{p['name']}"
        value = p['value']
        ssm.put_parameter(
          name: name_with_path,
          value: value,
          type: 'SecureString',
          key_id: key_id,
          overwrite: true
        )
      end
    end
    param_names = params.map{ |k,p| p['name'] }
    param_names.reject!{ |p| p.empty? }
    wait_until_params_created(path: path, names: param_names)
  end

  def wait_until_params_created(path:, names:)
    # there's a slight delay with creating params
    # this allows pausing until moving on
    created = 0
    while created == 0 do
      current_params = get_params_from_path(path: path)
      current_names = current_params.map{ |p| p[:name] }
      current_minus_names = (current_names - names)
      current_plus_names = (current_names & names)
      created = 1 if (current_names.sort & names.sort) == names.sort
      sleep(1)
    end
  end
end
