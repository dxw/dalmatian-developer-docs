class SSM
  def initialize(
    role_arn: '',
    role_session_name: ''
  )
    if role_arn.empty?
      @aws_ssm_client = Aws::SSM::Client.new
    else
      role_credentials = Aws::AssumeRoleCredentials.new(
        client: Aws::STS::Client.new,
        role_arn: role_arn,
        role_session_name: role_session_name
      )
      @aws_ssm_client = Aws::SSM::Client.new(credentials: role_credentials)
    end
  end

  def aws_ssm_client
    @aws_ssm_client
  end

  def describe_parameters
    params = Array.new
    aws_ssm_client.describe_parameters().each do |response|
      params.concat response.parameters
    end
    return params.sort_by { |a| [ a.name ] }
  end

  def get_paths(start_path: "/")
    paths = Set.new
    describe_parameters.each do |param|
      if param.name.start_with?(File.join(start_path, ""))
        paths.add(File.dirname(param.name))
      end
    end
    return paths.sort
  end

  def get_parameters_by_path(path: '/', with_decryption: true, recursive: false, role_to_assume: '')
    return get_parameters_by_path_recursive(path: path, with_decryption: with_decryption) if recursive
    params = Array.new
    aws_ssm_client.get_parameters_by_path(
      path: File.join(path, ""),
      with_decryption: with_decryption
    ).each do |response|
      params.concat response.parameters
    end
    return params.sort_by { |a| [ a.name ] }
  end

  def get_parameters_by_path_recursive(path: '/', with_decryption: true)
    params = {}
    paths = get_paths(start_path: path)
    paths.each do |p|
      params[p] = Array.new
      if p.start_with?(File.join(path, ""))
        path_params = get_parameters_by_path(path: p, with_decryption: with_decryption)
        params[p].concat path_params
      end
    end
    return params
  end

  def put_parameter(name: String, value: String, type: String, key_id: String, overwrite: false)
    ssm_options = {
      name: name,
      value: value,
      type: type,
      overwrite: overwrite
    }

    ssm_options.merge!(key_id: key_id) if type == "SecureString"
    resp = aws_ssm_client.put_parameter(ssm_options)
    return resp.version
  end

  def delete_parameters(names: Array)
    resp = aws_ssm_client.delete_parameters(
      names: names
    )
    return resp
  end
end
