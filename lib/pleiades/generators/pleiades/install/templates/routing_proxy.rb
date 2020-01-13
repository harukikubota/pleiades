Pleiades::Command::RoutingProxy.routing do
  #
  # EXAMPLE
  # if @event.source.user_id == 'Udeadbeefdeadbeefdeadbeefdeadbeef'
  #   mount line: 'config/pleiades/line'
  #   add 'line_dev', mnt: :line
  #   # => load by 'config/pleiades/line/line_dev.rb'
  # end
  #

  # only load by 'config/pleiades/router.rb'.
  default_routing
end
