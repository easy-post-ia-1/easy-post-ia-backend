# frozen_string_literal: true

require 'pagy/extras/limit' # works without further configuration
require 'pagy/extras/overflow'
require 'pagy/extras/array'

Pagy::DEFAULT[:limit] = 5
