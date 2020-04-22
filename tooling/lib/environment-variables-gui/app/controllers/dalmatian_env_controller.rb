class DalmatianEnv
  def initialize
    @dalmatian_config = DalmatianConfiguration.new
    @sts = Aws::STS::Client.new
  end

  def dalmatian_config
    @dalmatian_config
  end

  def dalmatian_parameter_store
    @dalmatian_parameter_store
  end

  def sts
    @sts
  end

  def infrastructures
    dalmatian_config.infrastructures
  end

  def infrastructure_account_id(infrastructure_name:)
    infrastructures[infrastructure_name]['account_id']
  end

  def current_account_id
    caller_identity = sts.get_caller_identity
    caller_identity.account
  end

  def get_service_envars(infrastructure_name:, service_name:, environment:)
    account_id = infrastructure_account_id(infrastructure_name: infrastructure_name)
    path = "/#{infrastructure_name}/#{service_name}/#{environment}/"
    DalmatianParameterStore.new(account_id: account_id).get_params_from_path(path: path)
  end

  def save_service_envars(infrastructure_name:, service_name:, environment:, service_envars:)
    account_id = infrastructure_account_id(infrastructure_name: infrastructure_name)
    path = "/#{infrastructure_name}/#{service_name}/#{environment}/"
    key_id = "alias/#{infrastructure_name}-#{service_name}-#{environment}-ssm"
    DalmatianParameterStore.new(account_id: account_id).save_params_to_path(path: path, params: service_envars, key_id: key_id)
  end

  def get_infrastructure_envars(infrastructure_name:, environment:)
    account_id = current_account_id
    path = "/dalmatian-variables/infrastructures/#{infrastructure_name}/#{environment}/"
    DalmatianParameterStore.new(account_id: account_id).get_params_from_path(path: path)
  end

  def save_infrastructure_envars(infrastructure_name:, environment:, infrastructure_envars:)
    account_id = current_account_id
    path = "/dalmatian-variables/infrastructures/#{infrastructure_name}/#{environment}/"
    key_id = "alias/dalmatian"
    DalmatianParameterStore.new(account_id: account_id).save_params_to_path(path: path, params: infrastructure_envars, key_id: key_id)
  end
end
