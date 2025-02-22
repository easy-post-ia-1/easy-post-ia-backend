# frozen_string_literal: true

# Artifacts helper
module ArtifactsHelper
  def self.upload_base64_to_s3(base64_string, file_name = 'default_file_name')
    require 'base64'
    require 'aws-sdk-s3'

    begin
      s3 = Aws::S3::Resource.new(region: 'us-east-2')
      decoded_data = Base64.decode64(base64_string)

      obj = s3.bucket(ENV.fetch('AWS_BUCKET_NAME_POST', nil)).object(file_name.to_s)
      obj.put(body: decoded_data, content_type: 'image/jpeg')
      obj.public_url
    rescue Aws::S3::Errors::ServiceError => e
      Rails.logger.error("S3 Upload Failed: #{e.message}")
      nil
    rescue StandardError => e
      Rails.logger.error("Unexpected Error: #{e.message}")
      nil
    end
  end
end
