require 'active_support/core_ext'

module Pleiades
  module Command
    module NestBlocks
      extend ActiveSupport::Concern

      def scope(*scopes, &block)
        scopes.each { |s| nest_block __callee__, s, &block }
      end
      alias :scope_append scope
      alias :scope_unshift scope

      def action(*actions, &block)
        actions.each { |a| nest_block __callee__, a, &block }
      end

      private

      def default_options
        {
          scope: [],
          action: ''
        }
      end

      def nest_block(method, context, &block)
        @_options = __send__ "merge_#{method}", context
        Pleiades::Command::Router.new(@_options).instance_eval(&block)
      end

      def merge_scope(context)
        operator =
          if /^merge_scope(_append)?$/ =~  __callee__
            :append
          elsif /^merge_scope_unshift$/ =~ __callee__
            :unshift
          end
        __merge__ ->(option) { option[:scope].__send__ operator, context }
      end
      alias :merge_scope_append merge_scope
      alias :merge_scope_unshift merge_scope

      def merge_action(context)
        __merge__ ->(option) { option[:action] = context }
      end

      def __merge__(proc)
        dup_options = @options.deep_dup
        proc.call(dup_options)
        dup_options
      end
    end
  end
end
