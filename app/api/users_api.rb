require 'json'


PDSApp.add_route('POST', '/v1/users', {
  "resourcePath" => "/Users",
  "summary" => "Create user",
  "nickname" => "create_user",
  "responseClass" => "Array<User>",
  "endpoint" => "/users",
  "notes" => "The body params are required to be a JSON object with an array of users. This endpoint supports bulk operations, you can create one or 1000 users in a single POST request.",
  "parameters" => [
    {
      "name" => "body",
      "description" => "Create user object(s)",
      "dataType" => "Array<ImmutableUserProperties>",
      "paramType" => "body",
    }
    ]}) do
  cross_origin
  # the guts live here

  # TODO: validation
  body = JSON.parse(request.body)

  begin
    data_adapter.create(:users, resources: body)
  rescue PDS::DataAdapter::Conflict => e
    status 400
    e.message
  end
end


PDSApp.add_route('DELETE', '/v1/users/{username}', {
  "resourcePath" => "/Users",
  "summary" => "Deletes a user",
  "nickname" => "delete_user",
  "responseClass" => "void",
  "endpoint" => "/users/{username}",
  "notes" => "This can only be done by the logged in user.",
  "parameters" => [
    {
      "name" => "username",
      "description" => "The username",
      "dataType" => "String",
      "paramType" => "path",
    },
    ]}) do
  cross_origin

  deleted = data_adapter.delete(:users, filters: [['=', 'username', params['username']]])
  if deleted.zero?
    status 404
  else
    status 200
  end
end


PDSApp.add_route('GET', '/v1/users', {
  "resourcePath" => "/Users",
  "summary" => "Get all available users",
  "nickname" => "get_all_users",
  "responseClass" => "Array<User>",
  "endpoint" => "/users",
  "notes" => "This can only be done by the logged in user with a superadmin role.",
  "parameters" => [
    ]}) do
  cross_origin
  # the guts live here

  all_users = data_adapter.read(:users)
  all_users.map { |hash| hash.select { |key,_| key != 'temp_token' }}.to_json
end


PDSApp.add_route('GET', '/v1/users/{username}/token', {
  "resourcePath" => "/Users",
  "summary" => "Get API token by username",
  "nickname" => "get_token_by_username",
  "responseClass" => "Token",
  "endpoint" => "/users/{username}/token",
  "notes" => "Retrieve an API token for the user",
  "parameters" => [
    {
      "name" => "username",
      "description" => "The username",
      "dataType" => "String",
      "paramType" => "path",
    },
    ]}) do
  cross_origin
  # the guts live here

  user = data_adapter.read(:users, filters: [['=', 'username', params['username']]])
  if user.empty?
    status 404
  else
    { 'token' => user.first['temp_token']}.to_json
  end
end


PDSApp.add_route('GET', '/v1/users/{username}', {
  "resourcePath" => "/Users",
  "summary" => "Get user by username",
  "nickname" => "get_user_by_username",
  "responseClass" => "User",
  "endpoint" => "/users/{username}",
  "notes" => "Retrieve a specific user.",
  "parameters" => [
    {
      "name" => "username",
      "description" => "The username",
      "dataType" => "String",
      "paramType" => "path",
    },
    ]}) do
  cross_origin
  # the guts live here

  user = data_adapter.read(:users, filters: [['=', 'username', params['username']]])

  if user
    user.map { |hash| hash.select { |key,_| key != 'temp_token' }}.to_json
  else
    status 404
  end
end


PDSApp.add_route('PUT', '/v1/users/{username}', {
  "resourcePath" => "/Users",
  "summary" => "Create a new user or replace an existing user",
  "nickname" => "put_user",
  "responseClass" => "User",
  "endpoint" => "/users/{username}",
  "notes" => "If the username does not exist, it will create it for you. This endpoint does not support bulk operations",
  "parameters" => [
    {
      "name" => "username",
      "description" => "The username",
      "dataType" => "String",
      "paramType" => "path",
    },
    {
      "name" => "body",
      "description" => "Create or edit user object",
      "dataType" => "UNKNOWN_BASE_TYPE",
      "paramType" => "body",
    }
    ]}) do
  cross_origin
  # the guts live here

  body = JSON.parse(request.body)
  # TODO: validate input
  data_adapter.upsert(:users, resources: [body])
end

