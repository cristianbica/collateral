# frozen_string_literal: true

module Collateral
  module Commands
    class ProjectGenerator < Thor::Group
      include Thor::Actions

      argument :name

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

      def create_files
        copy_file "Gemfile", "#{snake_name}/Gemfile"
        copy_file "boot.rb", "#{snake_name}/boot.rb"
      end

      def create_config_files
        template "config/redis.yml", "#{snake_name}/config/redis.yml"
      end

      def create_dot_files
        copy_file "rubocop.yml", "#{snake_name}/.rubocop.yml"
        copy_file "gitignore", "#{snake_name}/.gitignore"
      end

      def keep_dirs
        create_file "#{snake_name}/config/.keep"
        create_file "#{snake_name}/data/.keep"
        create_file "#{snake_name}/lib/.keep"
        create_file "#{snake_name}/log/.keep"
      end

      def install_gems
        inside snake_name do
          run "bundle install"
        end
      end
    end
  end
end
