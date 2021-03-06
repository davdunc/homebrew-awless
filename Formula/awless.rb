class Awless < Formula
  version = "v0.1.9"

  desc "The Mighty CLI for AWS"
  homepage "https://github.com/wallix/awless"
  url "https://github.com/wallix/awless.git",
        :tag => version
  head "https://github.com/wallix/awless.git"

  bottle do
    root_url "https://github.com/wallix/homebrew-awless/releases/download/#{version}"
    cellar :any_skip_relocation
    sha256 "445395a4464ab14ff11efc019197479ee7a039b2d8b021b51449f4caa0e0d469" => :sierra
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    arch = MacOS.prefer_64_bit? ? "amd64" : "x86"
    dir = buildpath/"src/github.com/wallix/awless"
    dir.install buildpath.children - [buildpath/".brew_home"]

    cd dir do
      # Make binary
      system "go", "run", "release.go", "-tag", "v#{version}", "-brew", "-arch", "#{arch}", "-os", "darwin"
      bin.install "awless"

      # Install bash completion
      output = Utils.popen_read("#{bin}/awless completion bash")
      (bash_completion/"awless").write output

      # Install zsh completion
      output = Utils.popen_read("#{bin}/awless completion zsh")
      (zsh_completion/"_awless").write output
    end
  end

  def caveats
    <<-EOS.undent

      In order to get awless completion,
        [bash] you need to install `bash-completion` with brew.
        OR
        [zsh], add the following line to your ~/.zshrc:
          source #{HOMEBREW_PREFIX}/share/zsh/site-functions/_awless
    EOS
  end

  test do
    run_output = shell_output("#{bin}/awless --help 2>&1")
    assert_match "Awless is a powerful command line tool to inspect, sync and manage your infrastructure", run_output
  end
end
