import Config

config :logger,
  backends: [{LoggerFileBackend, :error_log}]

# configuration for the {LoggerFileBackend, :error_log} backend
config :logger, :error_log,
  path: "error.log",
  level: :error
