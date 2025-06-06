class GameQrCode
  def initialize(game)
    @game = game
  end

  def svg
    require "rqrcode"
    qrcode = RQRCode::QRCode.new(@game.join_url)
    # Safe: This is a self-generated SVG QR code with no user input
    qrcode.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 6,
      standalone: true,
      use_path: true
    ).html_safe
  end

  private

  attr_reader :game
end
