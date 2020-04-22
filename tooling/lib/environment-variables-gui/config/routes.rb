dalmatian_env = DalmatianEnv.new

get '/' do
  erb :index, :locals => {
    :infrastructures => dalmatian_env.infrastructures,
  }
end

get '/service-environment-variables/*/*' do
  infrastructure_name = params['splat'][0]
  service_name       = params['splat'][1]
  environment        = params['environment'] || 'none'
  service_envars = environment != 'none' ? dalmatian_env.get_service_envars(
    infrastructure_name: infrastructure_name,
    service_name: service_name,
    environment: environment
  ) : {}
  erb :envlist, :locals => {
    :infrastructures => dalmatian_env.infrastructures,
    :infrastructure_name => infrastructure_name,
    :title           => "#{service_name} environment variables",
    :environment     => environment,
    :envars  => service_envars,
  }
end

post '/service-environment-variables/*/*' do
  infrastructure_name = params['splat'][0]
  service_name       = params['splat'][1]
  environment        = params['environment'] || 'none'
  service_envars     = params['envars']
  dalmatian_env.save_service_envars(
    infrastructure_name: infrastructure_name,
    service_name: service_name,
    environment: environment,
    service_envars: service_envars
  )
  redirect "/service-environment-variables/#{infrastructure_name}/#{service_name}?environment=#{environment}", 302
end

get '/infrastructure-variables/*' do
  infrastructure_name = params['splat'][0]
  environment         = params['environment'] || 'none'
  infrastructure_envars = environment != 'none' ? dalmatian_env.get_infrastructure_envars(
    infrastructure_name: infrastructure_name,
    environment: environment
  ) : {}
  erb :envlist, :locals => {
    :infrastructures => dalmatian_env.infrastructures,
    :infrastructure_name => infrastructure_name,
    :title           => "#{infrastructure_name} infrastructure variables",
    :environment     => environment,
    :envars  => infrastructure_envars
  }
end

post '/infrastructure-variables/*' do
  infrastructure_name    = params['splat'][0]
  environment            = params['environment'] || 'none'
  infrastructure_envars  = params['envars']
  dalmatian_env.save_infrastructure_envars(
    infrastructure_name: infrastructure_name,
    environment: environment,
    infrastructure_envars: infrastructure_envars
  )
  redirect "/infrastructure-variables/#{infrastructure_name}?environment=#{environment}", 302
end

get '/check' do
  'OK'
end
