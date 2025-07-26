# frozen_string_literal: true

# app/controllers/concerns/rack_session_fix
#
# :nocov:
module RackSessionFix
  extend ActiveSupport::Concern
  # Fake rack session to update project to be only API
  class FakeRackSession < Hash
    def enabled?
      false
    end
  end
  included do
    before_action :set_fake_rack_session_for_devise

    private

    def set_fake_rack_session_for_devise
      request.env['rack.session'] ||= FakeRackSession.new
    end
  end
end
# :nocov:
