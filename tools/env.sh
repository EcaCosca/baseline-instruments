#!/usr/bin/env bash
# Source this before running REA or any JADX/Apktool work:
#     source tools/env.sh
#
# Sets a modern JDK for this shell only. The system default stays at Java 1.8
# so nothing else on the machine changes.

export JAVA_HOME="/opt/homebrew/opt/openjdk@21"
export PATH="$JAVA_HOME/bin:$PATH"

echo "JAVA_HOME = $JAVA_HOME"
java -version 2>&1 | head -1
echo "node      = $(node --version 2>/dev/null) (from .tool-versions via asdf)"
