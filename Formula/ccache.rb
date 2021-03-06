require "formulary"

module CcacheToolchain
  def post_install
    super

    ohai "Installing Xcode toolchain"

    toolchain_identifier = 'sh.brew.ccache'
    toolchain_info = {
      'CompatibilityVersion' => 2,
      'CFBundleIdentifier' => toolchain_identifier,
      'Aliases' => ['ccache'],
      'DisplayName' => "ccache #{version} (Homebrew)",
      'ShortDisplayName' => "ccache #{version}",
      'ReportProblemURL' => 'https://github.com/torarnv/homebrew-xcode-toolchains'
    }

    toolchain = prefix/"xctoolchain"
    toolchain.mkpath

    wrapper_script = libexec/"ccache.sh"
    wrapper_script.write <<~EOS
      #!/bin/sh
      # Fall back to next toolchain in line
      read -r _ TOOLCHAINS <<< "$TOOLCHAINS"
      exec #{opt_libexec}/$(basename $0) $*
    EOS
    chmod 0755, wrapper_script

    usrbin = toolchain/"usr/bin"
    usrbin.mkpath
    libexec.each_child do |prog|
      next if not prog.symlink?
      usrbin.install_symlink wrapper_script => prog.basename
    end

    cd toolchain do
      info_plist_file = "Info.plist"
      File.open info_plist_file, "w" do |f|
        f.write toolchain_info.to_json
      end
      system "plutil", "-convert", "xml1", info_plist_file
    end

    mkdir "/Users/#{ENV["USER"]}/Library/Developer/Toolchains" do
      toolchain_link = "#{toolchain_identifier}.xctoolchain"
      File.unlink toolchain_link if File.exists? toolchain_link
      File.symlink toolchain, toolchain_link
    end
  end

  def caveats
    super + "\n" + <<~EOS
    To use the Xcode toolchain, select it in the Xcode preferences,
    pass --toolchain ccache to xcrun, or export TOOLCHAINS=ccache.
    EOS
  end

  # Masquerade as not coming from a tap, to pour the default bottle
  def tap
    nil
  end

  private

  # Use puts instead of ohai for verbose output
  def system(cmd, *args)
    alias :ohai_original :ohai
    def ohai(msg)
      puts msg if ARGV.verbose?
    end
    super
    alias :ohai :ohai_original
  end
end

# Homebrew doesn't support meta-packages that just depend on other formulas,
# only adding post-installation steps. As a workaround we look up the formula
# for ccache and inherit it.
Ccache = Formulary.factory("ccache").class
Ccache.send :prepend, CcacheToolchain
