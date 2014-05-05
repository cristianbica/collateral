module Collateral
  module Commands
    class ProjectGenerator < Thor::Group
      include Thor::Actions
      argument :name
      argument :pipelines

      def create_project_directory

      end

      def create_gemfile

      end

      def method_name

      end
    end
  end
end
