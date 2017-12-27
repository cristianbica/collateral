# frozen_string_literal: true

module Collateral
  module Commands
    class PipelineGenerator < Thor::Group
      include Thor::Actions

      add_runtime_options!

      argument :name
      argument :actions

      def self.source_root
        File.expand_path("../../../template", __FILE__)
      end

      def name_components
        @_name_components ||= name.scan(/[[:alnum:]]+/)
      end

      def dash_name
        @_dash_name ||= name_components.map(&:downcase).join("-")
      end

      def snake_name
        @_snake_name ||= name_components.map(&:downcase).join("_")
      end

      def camel_name
        @_camel_name ||= name_components.map(&:capitalize).join("")
      end

      def create_pipeline_files
        template "bin/pipeline", "bin/#{snake_name}"
        chmod "bin/#{snake_name}", 0o0755
        template "lib/pipeline.rb", "lib/#{snake_name}.rb"
      end

      def create_actions_files
        actions.each do |action|
          template "lib/pipeline/action.rb", "lib/#{snake_name}/#{action}.rb", action: action
        end
      end
    end
  end
end
