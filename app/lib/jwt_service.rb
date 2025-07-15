module JwtService
  ACCESS_SECRET_KEY = Settings.jwt_secret
  REFRESH_SECRET_KEY = Settings.refresh_jwt_secret

  def self.encode payload, exp = Settings.access_token_time.hours.from_now,
    type: :access
    payload[:exp] = exp.to_i
    payload[:type] = type.to_s
    secret = type == :refresh ? REFRESH_SECRET_KEY : ACCESS_SECRET_KEY
    JWT.encode(payload, secret)
  end

  def self.decode token, type: :access
    secret = type == :refresh ? REFRESH_SECRET_KEY : ACCESS_SECRET_KEY
    decoded = JWT.decode(token, secret)[0]
    payload = HashWithIndifferentAccess.new(decoded)
    return nil unless payload[:type] == type.to_s

    payload
  rescue JWT::ExpiredSignature
    nil
  rescue JWT::DecodeError
    nil
  end
end
