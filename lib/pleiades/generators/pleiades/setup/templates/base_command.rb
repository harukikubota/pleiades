class BaseCommand < Pleiades::Command::BaseCommand
  def call
    show_event if disp?
  end

  private

  def disp?
    Rails.env.development? && Pleiades::Config.debug.disp_console
  end

  def show_event
    mes = <<~MES


      |------------------------------------|
      | There is no corresponding command. |
      |------------------------------------|

      event:#{@event.type}
    MES

    mes.split("\n").each { |m| p m }
  end
end
