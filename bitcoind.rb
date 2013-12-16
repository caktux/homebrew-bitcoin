require 'formula'

class Bitcoind < Formula
  homepage 'http://bitcoin.org/'
  head 'https://github.com/bitcoin/bitcoin.git'
  url 'https://github.com/bitcoin/bitcoin.git', :tag => 'v0.8.6'
  version '0.8.6'

  head do
    url 'https://github.com/bitcoin/bitcoin.git', :branch => 'master'
    version 'master'

    depends_on 'automake'
    depends_on 'pkg-config'
    depends_on 'protobuf'
  end

  depends_on 'berkeley-db4'
  depends_on 'boost'
  depends_on 'miniupnpc' if build.include? 'with-upnp'
  depends_on 'openssl'

  option 'with-upnp', 'Compile with UPnP support'
  option 'without-ipv6', 'Compile without IPv6 support'

  def patches
    unless build.head?
      # fix include and lib paths for berkeley-db4 and openssl
      DATA
    end
  end

  def install
    raise 'Bitcoind currently requires --HEAD on Mavericks.' if MacOS.version == :mavericks and not build.head?

    if build.head?
      system "sh", "autogen.sh"
      system "./configure", "--prefix=#{prefix}"
      system "make"
    else
      cd "src" do
        system "make", "-f", "makefile.osx",
          "DEPSDIR=#{HOMEBREW_PREFIX}",
          "USE_UPNP=#{(build.include? 'with-upnp') ? '1' : '-'}",
          "USE_IPV6=#{(build.include? 'without-ipv6') ? '-' : '1'}"
      end
    end

    system "strip src/bitcoind"
    bin.install "src/bitcoind"
  end

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_prefix}/bin/bitcoind</string>
          <string>-daemon</string>
        </array>
      </dict>
    </plist>
    EOS
  end

  def caveats; <<-EOS.undent
    You will need to setup your bitcoin.conf if you haven't already done so:

    echo -e "rpcuser=bitcoinrpc\\nrpcpassword=$(xxd -l 16 -p /dev/urandom)" > ~/Library/Application\\ Support/Bitcoin/bitcoin.conf
    chmod 600 ~/Library/Application\\ Support/Bitcoin/bitcoin.conf

    Use `bitcoind stop` to stop bitcoind if necessary! `brew services stop bitcoind` does not work!
    EOS
  end
end
__END__
diff --git a/src/makefile.osx b/src/makefile.osx
index 50279fd..6ab92b1 100644
--- a/src/makefile.osx
+++ b/src/makefile.osx
@@ -7,18 +7,22 @@
 # Originally by Laszlo Hanyecz (solar@heliacal.net)
 
 CXX=llvm-g++
 DEPSDIR=/opt/local
+DB4DIR=$(DEPSDIR)/opt/berkeley-db4
+OPENSSLDIR=$(DEPSDIR)/opt/openssl
 
 INCLUDEPATHS= \
  -I"$(CURDIR)" \
- -I"$(CURDIR)"/obj \
+ -I"$(CURDIR)/obj" \
  -I"$(DEPSDIR)/include" \
- -I"$(DEPSDIR)/include/db48"
+ -I"$(DB4DIR)/include" \
+ -I"$(OPENSSLDIR)/include"
 
 LIBPATHS= \
  -L"$(DEPSDIR)/lib" \
- -L"$(DEPSDIR)/lib/db48"
+ -L"$(DB4DIR)/lib" \
+ -L"$(OPENSSLDIR)/lib"
 
 USE_UPNP:=1
 USE_IPV6:=1
 
@@ -31,13 +35,13 @@ ifdef STATIC
 TESTLIBS += \
  $(DEPSDIR)/lib/libboost_unit_test_framework-mt.a
 LIBS += \
- $(DEPSDIR)/lib/db48/libdb_cxx-4.8.a \
+ $(DB4DIR)/lib/libdb_cxx-4.8.a \
  $(DEPSDIR)/lib/libboost_system-mt.a \
  $(DEPSDIR)/lib/libboost_filesystem-mt.a \
  $(DEPSDIR)/lib/libboost_program_options-mt.a \
  $(DEPSDIR)/lib/libboost_thread-mt.a \
  $(DEPSDIR)/lib/libboost_chrono-mt.a \
- $(DEPSDIR)/lib/libssl.a \
- $(DEPSDIR)/lib/libcrypto.a \
+ $(OPENSSLDIR)/lib/libssl.a \
+ $(OPENSSLDIR)/lib/libcrypto.a \
  -lz
 else
 TESTLIBS += \
