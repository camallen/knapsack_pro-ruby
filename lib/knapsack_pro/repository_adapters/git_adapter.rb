module KnapsackPro
  module RepositoryAdapters
    class GitAdapter < BaseAdapter
      def commit_hash
        `git -C "#{working_dir}" rev-parse HEAD`.strip
      end

      def branch
        `git -C "#{working_dir}" rev-parse --abbrev-ref HEAD`.strip
      end

      def branches
        str_branches = `git rev-parse --abbrev-ref --branches`
        str_branches.split("\n")
      end

      def commit_authors
        KnapsackPro.logger.debug("Looking up the commit authors from git")
        authors = git_commit_authors
          .split("\n")
          .map { |line| line.strip }
          .map { |line| line.split("\t") }
          .map do |commits, author|
            { commits: commits.to_i, author: KnapsackPro::MaskString.call(author) }
          end

        raise if authors.empty?
        KnapsackPro.logger.debug("Found the authorse and moving on with life")

        authors
      rescue Exception
        []
      end

      def build_author
        KnapsackPro.logger.debug("Found the authorse and moving on with life")
        author = KnapsackPro::MaskString.call(git_build_author.strip)
        raise if author.empty?
        author
      rescue Exception
        "no git <no.git@example.com>"
      end

      private

      def git_commit_authors
        if KnapsackPro::Config::Env.ci? && !ENV.fetch("SKIP_KP_GIT_FETCH", false)
          KnapsackPro.logger.debug("running CI git fetch in git_commit_authors lookup")
          # `git fetch --shallow-since "one month ago" --quiet 2>/dev/null`
          `git fetch --shallow-since "one month ago"`
        end

        KnapsackPro.logger.debug("getting the authors from the git log")

        results = `git --no-pager log --since "one month ago" 2>/dev/null | git --no-pager shortlog --summary --email 2>/dev/null`

        KnapsackPro.logger.debug("done getting the authors from the git log!")
        results
      end

      def git_build_author
        KnapsackPro.logger.debug("getting the build author from the git log!")

        `git --no-pager log --format="%aN <%aE>" -1 2>/dev/null`
      end

      def working_dir
        dir = KnapsackPro::Config::Env.project_dir
        File.expand_path(dir)
      end
    end
  end
end
