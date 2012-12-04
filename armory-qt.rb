  head 'https://github.com/etotheipi/BitcoinArmory/archive/master.tar.gz'
  url 'https://github.com/etotheipi/BitcoinArmory/archive/v0.85-beta.tar.gz'
  sha1 '26354bdb5096ea4a9aeccbf1c80e103fb89c72a1'
  version 'v0.85-beta'

  def patches
    DATA
  end

    # my makefile patches weren't working
    system "mkdir -p #{prefix}/share/armory/img"
    system "cp *.py *.so README LICENSE #{prefix}/share/armory/"
    system "cp img/* #{prefix}/share/armory/img"
    ArmoryQt.command was installed in
        ln -s #{bin}/ArmoryQt.command ~/Applications/ArmoryQt

    Or you can just run 'ArmoryQt.command' from your terminal

__END__
diff --git a/ArmoryQt.command b/ArmoryQt.command
new file mode 100644
index 0000000..2cc2154
--- /dev/null
+++ b/ArmoryQt.command
@@ -0,0 +1,3 @@
+#!/bin/sh
+PYTHONPATH=`brew --prefix`/lib/python2.7/site-packages /usr/bin/python `brew --prefix`/share/armory/ArmoryQt.py
+