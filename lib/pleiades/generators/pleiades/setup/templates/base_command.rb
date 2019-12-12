class BaseCommand < Pleiades::Command::BaseCommand
  include CommandCommon

  def call
    success!
    show_event if disp?
  end

  private

  def disp?
    Rails.env.development? && Pleiades::Config.disp_console
  end

  def show_event
    mes = <<~MES
      \n
      \n
      |------------------------------------|
      | There is no corresponding command. |
      |------------------------------------|
      \n
      event:#{@event.type}
    MES

    p mes
  end
end
