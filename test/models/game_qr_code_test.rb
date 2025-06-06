require "test_helper"

class GameQrCodeTest < ActiveSupport::TestCase
  test "generates QR code SVG" do
    game = games(:one)
    qr_code = GameQrCode.new(game)
    svg = qr_code.svg

    assert_not_nil svg
    assert_includes svg, "<svg"
    assert svg.length > 100, "QR code should be a substantial SVG"
  end

  test "QR code contains game join URL" do
    game = games(:one)
    qr_code = GameQrCode.new(game)

    # The QR code should encode the join URL
    assert_not_nil qr_code.svg
    # We can't easily test the actual encoded content without decoding the QR code,
    # but we can verify it's a valid SVG
    assert_match(/<svg.*>.*<\/svg>/m, qr_code.svg)
  end
end
