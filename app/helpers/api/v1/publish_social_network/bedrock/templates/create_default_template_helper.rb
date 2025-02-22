# frozen_string_literal: true

require 'aws-sdk-bedrock'

module Api
  module V1
    module PublishSocialNetwork
      # Post helper
      module Bedrock
        # Post helper for creating posts using Bedrock
        module Templates
          module CreateDefaultTemplateHelper
            # app/helpers/marketing_helper.rb
            module MarketingHelper
              def self.generate_marketing_strategy_template(number_of_posts: 2, start_date: Time.zone.today,
                                                            end_date: Time.zone.today + 14.days, user_strategy: '')
                template = <<~TEMPLATE
                  Genera una estrategia de mercadeo con un máximo de #{number_of_posts} publicaciones por semana en el rango de fechas entre #{start_date} y #{end_date}, donde cada publicación tiene los siguientes detalles:

                  - **title**: El título debe ser conciso y atractivo.
                  - **description**: Descripción breve pero completa de la publicación.
                  - **image_prompt**: Un detalle visual o idea para la imagen que acompañará la publicación.
                  - **tags**: Hashtags o palabras clave relevantes.
                  - **programming_date_to_post**: Fecha en formato ISO (YYYY-MM-DDTHH:MM:SS+00:00) para la programación de la publicación.

                  **Ejemplo de respuesta que me debes dar en JSON:**
                  [
                    {
                      "title": "Título del post",
                      "description": "Descripción breve pero completa de la publicación.",
                      "image_prompt": "Detalle visual o idea para la imagen que acompañará la publicación.",
                      "tags": ["#marketing", "#estrategia"],
                      "programming_date_to_post": "YYYY-MM-DDTHH:MM:SS+00:00"
                    },
                  ]

                  **Reglas**
                  1. Máximo 2 prompt por semana nada más así te lo pidan.
                  2. Si no hay una fecha, solo toma la actual y 2 semanas después.
                  3. Si no hay estrategia escrita genera una genérica.
                  4. No confirmes nada solo manda el prompt.
                  5. No lenguaje, imagenes, sugerencias obscenas o inapropiadas para publicar en las diferentes redes sociales.
                  6. No generes codigo en otro lenguaje que no sea JSON.


                  **Por favor, ajusta las fechas y los contenidos según las preferencias del usuario y las necesidades del mercado y entregame la respuesta en formato JSON.**
                TEMPLATE

                template.strip
              end
            end
          end
        end
      end
    end
  end
end
