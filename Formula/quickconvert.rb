class Quickconvert < Formula
  desc "Convert files from Finder's right-click menu: images, video, audio, PDFs, documents"
  homepage "https://github.com/jgreen417/QuickConvert"
  url "https://github.com/jgreen417/QuickConvert/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "6cffc1092558639dbb8d136b52b955c24532a50672b11aee5963cd8a05e25029"
  license "MIT"

  depends_on macos: :ventura
  depends_on "ffmpeg"
  depends_on "imagemagick"
  depends_on "librsvg"
  depends_on "poppler"

  def install
    # Built on this Mac, so an ad-hoc signature is all macOS needs (no notarization involved).
    ENV["IDENTITY"] = "-"
    ENV["ARCHS"] = Hardware::CPU.arm? ? "arm64" : "x86_64"
    system "./build.sh", "--no-install"
    prefix.install "build/QuickConvert.app"
    inreplace "bin/quickconvert", "@APP@", "#{opt_prefix}/QuickConvert.app"
    bin.install "bin/quickconvert"
  end

  def caveats
    <<~EOS
      To finish installing, run:
        quickconvert setup
      It copies QuickConvert to ~/Applications, enables the Finder extension,
      and relaunches Finder. Run it again after `brew upgrade quickconvert`.

      For Word, Excel, PowerPoint, Keynote and Numbers files (and anything → PDF):
        brew install --cask libreoffice

      To remove everything:
        quickconvert uninstall && brew uninstall quickconvert
    EOS
  end

  test do
    assert_match "quickconvert setup", shell_output("#{bin}/quickconvert --help")
    app = prefix/"QuickConvert.app"
    system "codesign", "--verify", "--deep", "--strict", app
    assert_match "app-sandbox",
      shell_output("codesign -d --entitlements - #{app}/Contents/PlugIns/QuickConvertFinder.appex 2>&1")
  end
end
