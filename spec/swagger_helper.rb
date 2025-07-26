# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'swagger.json' => {
      openapi: '3.1.0',

      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      servers: [
        {
          url: '{defaultHost}',
          variables: {
            defaultHost: {
              default: "http://localhost:#{ENV.fetch('API_PORT', 4000)}"
            }
          }
        }
      ],
      basePath: '/api/v1',
      components: {
        # Removed the first, now duplicate, securitySchemes definition.
        securitySchemes: {
          Bearer: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT'
          }
        },
        schemas: {
          StatusSuccess: { # Defines the structure of the 'status' object itself
            type: :object,
            properties: {
              code: { type: :integer, example: 200 },
              message: { type: :string, example: 'Success' }
            },
            required: %w[code message]
          },
          StatusUnauthorized: { # Defines the structure of the 'status' object for unauthorized
            type: :object,
            properties: {
              code: { type: :integer, example: 401 },
              message: { type: :string, example: 'Unauthorized' }
            },
            required: %w[code message]
            # NOTE: The main response schema using this might add an 'errors' array separately
            # if the controller for 401 sometimes returns errors (e.g. Devise does for failed login attempts)
            # For a simple "token missing/invalid" 401, often no error body beyond status.
          },
          StatusNotFound: { # Defines the structure for a 'status' object for not found
            type: :object,
            properties: {
              code: { type: :integer, example: 404 }, # Standard HTTP Not Found
              message: { type: :string, example: 'Resource not found' }
            },
            required: %w[code message]
            # The main response schema using this will add the 'errors' array:
            # properties: {
            #   status: { '$ref': '#/components/schemas/StatusNotFound' },
            #   errors: { type: :array, items: { type: :string }, example: ["Resource not found."] }
            # }
          },
          StatusError: { # Defines the structure for a generic 'status' object for errors (e.g. 422)
            type: :object,
            properties: {
              code: { type: :integer, example: 422 }, # Example: Unprocessable Entity
              message: { type: :string, example: 'Error' } # Or specific error message
            },
            required: %w[code message]
            # The main response schema using this will add the 'errors' array:
            # properties: {
            #   status: { '$ref': '#/components/schemas/StatusError' },
            #   errors: { type: :array, items: { type: :string }, example: ["Validation failed: Details..."] }
            # }
          },
          Pagination: {
            type: :object,
            properties: {
              page: { type: :integer, example: 1, description: 'Current page number' },
              per_page: { type: :integer, example: 10, description: 'Items per page' },
              pages: { type: :integer, example: 5, description: 'Total number of pages' },
              count: { type: :integer, example: 42, description: 'Total number of items' }
            },
            required: %w[page per_page pages count]
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :json
end
