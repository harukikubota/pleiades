class BaseCommand < Pleiades::Command::BaseCommand
  def call
    show_event if disp?
  end

  private

  def disp?
    Rails.env.development? && Pleiades::Config.debug.disp_console
  end

  def show_event
    p <<~MES
      \n
      \n
      |------------------------------------|
      | There is no corresponding command. |
      |------------------------------------|
      \n
      event:#{@event.type}
    MES
  end
end
