Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins "http://localhost:3000"
      resource "/api/v1/*",
               headers: :any,
               methods: [:get, :post, :put, :patch, :delete, :options],
               credentials: true,
               expose: ["Authorization"],
               max_age: Settings.cache
    end
  end
