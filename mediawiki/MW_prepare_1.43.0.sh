#!/bin/bash
#
# MediaWiki Release Cleanup Script
# MediaWiki is bundled with thousands of translation files and all sorts of
# additional information which are not necessary for running the wiki online.
# This script tries to remove all non-German and non-English translations,
# all but the Vector skin, unused extensions, the tests and several other
# files.
#
# Future versions might remove all the unit tests contained in subdirectories
# as well.
#
# The reason behind removing this is that I do not see the point in copying
# and moving around unused files all the time. Also, I use Git to manage the
# wiki nowadays and the fewer files I have in under version control the
# better.
#
# Also, seeing that MediaWiki was feature-complete for my requirements at the
# latest at 1.30.0 it baffles me every time I am preparing the script for the
# latest version just how much item count and size inflate over time.
#
# Effect (MW + CodeMirror + intersection)
# 33,304 items (356.4 MiB) -> 8,887 items (74.9 MiB)
#
# For comparison: MW 1.31.0 (without negligble contribution from CodeMirror 
# and intersection), 2018-07-29
# 14,574 items (139.8 MiB) -> 5,571 items (31.6 MiB)
# +129%         +155%        +59.5%       +137%
#
# WARNING: Most likely, this script is not suitable for you out of the box.
# Use at your own discretion after carefully checking what this script
# does/intends to do.
#
# Author: Steven 'Kreuvf' Koenig
# Created: 2025-03-05
# Licence: Creative Commons Attribution 4.0 International Public License

if ! [[ "$1" =~ ^(\./)?(mediawiki.*|wiki.dsa.isurandil.net) ]];
then
	echo "Argument does not start with '(\./)?(mediawiki.*|wiki.dsa.isurandil.net)'. Aborting ..."
	exit 1
fi

if [ ! -d "$1" ];
then
	echo "Argument is either not a directory or does not exist. Aborting ..."
	exit 1
fi

# Gather translation files for deletion
touch MW_prepare_i18n_deletion.lst
find ./"$1"/extensions/Cite/i18n/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/extensions/Cite/modules/ve-cite/i18n/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/extensions/Cite/modules/ -maxdepth 1 -regextype posix-extended -regex '.*/ext\.cite\.style\..*\.css$' -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/extensions/CiteThisPage/i18n/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/extensions/CodeMirror/i18n/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/extensions/ParserFunctions/i18n/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/extensions/Poem/i18n/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/extensions/WikiEditor/i18n/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/includes/api/i18n/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/includes/installer/i18n/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/includes/Rest/i18n/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/includes/libs/ParamValidator/i18n/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/languages/i18n/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/languages/data/grammarTransformations/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/languages/messages/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/resources/lib/jquery.i18n/src/languages/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/resources/lib/jquery.i18n/src/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/resources/lib/jquery.i18n/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/resources/lib/jquery.ui/i18n/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/resources/lib/moment/locale/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/resources/lib/ooui/i18n/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/skins/Vector/i18n/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/vendor/oojs/oojs-ui/i18n/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/vendor/wikimedia/parsoid/baseconfig/ -type f >> MW_prepare_i18n_deletion.lst

# Files in non-standard extensions
find ./"$1"/extensions/intersection/i18n -type f >> MW_prepare_i18n_deletion.lst

# Remove all non-translation files
sed -i -r -e '/(php|js(on)?|css)$/!d' MW_prepare_i18n_deletion.lst
sed -i -r -e '/\/jquery\.i18n(\.[a-zA-Z]+)*\.js$/d' MW_prepare_i18n_deletion.lst

# Remove all de and en language files (we want to save them <3)
sed -i -r -e '/(de|en)(wiki)?([-_][-_a-zA-Z]+)?\.js(on)?$/d' MW_prepare_i18n_deletion.lst
sed -i -r -e '/LanguageEn\.php$/d' MW_prepare_i18n_deletion.lst
sed -i -r -e '/Messages(De|En)\.php$/d' MW_prepare_i18n_deletion.lst
sed -i -r -e '/ext\.cite\.style\.((de|en)([^.]*))\.css$/d' MW_prepare_i18n_deletion.lst

# Quote strings
cp MW_prepare_i18n_deletion.lst MW_prepare_i18n_deletion-rescue-clean.txt
sed -i -r -e 's/^(.*)$/'\''\1'\''/' MW_prepare_i18n_deletion.lst
# Remove all the crap
xargs --arg-file=MW_prepare_i18n_deletion.lst /bin/rm -f

# Remove intermediary file, thank you file
rm MW_prepare_i18n_deletion.lst

# Gather .phan directories
touch MW_prepare_phan_deletion.lst
find ./"$1"/ -type d -regextype posix-extended -regex '.*/\.phan$' >> MW_prepare_phan_deletion.lst

# Remove all the crap
xargs --arg-file=MW_prepare_phan_deletion.lst /bin/rm -f --recursive

# Remove intermediary file, thank you file
rm MW_prepare_phan_deletion.lst

# Gather everything in "vendor" that looks like a test (they are not run afaik)
touch MW_prepare_tests_deletion.lst
find ./"$1"/ -type d -regextype posix-extended -iregex '.*/vendor/.*test.*$' >> MW_prepare_tests_deletion.lst
find ./"$1"/ -type f -regextype posix-extended -iregex '.*/vendor/.*test.*$' | xargs /bin/rm -f >> MW_prepare_tests_deletion.lst

# Remove false-positives
sed -i -r -e '/InflateStream\.php$/d' MW_prepare_tests_deletion.lst

# Remove all the crap
xargs --arg-file=MW_prepare_tests_deletion.lst /bin/rm -f --recursive

# Remove intermediary file, thank you file
rm MW_prepare_tests_deletion.lst

# Gather files unnecessary for just running the wiki
find ./"$1"/ -type f -regextype posix-extended -regex '.*(\.editorconfig|\.(es|style)lintrc\.json|\.git(ignore|review)|\.scrutinizer\.yml|\.stylelintrc|(APACHE|GPL|MIT)?-?LICENSE-?(2\.0|MIT)?(\.txt)?|API\.md|AUTHORS(\.txt)?|BUILD\.md|changelog\.txt|CHANGELOG(\.md)?|CHANGES\.md|CODE_OF_CONDUCT\.md|composer\.local\.json-sample|CONTRIBUTING\.md|COPYING(\.txt)?|CREDITS|dependencies\.txt|DEPRECATED|Doxyfile|errors\.md|example_debug\.png|FAQ|formats\.md|Gemfile\.lock|gitinfo\.json|Gruntfile\.js|History(\.md)?|HISTORY(\.md)?|INSTALL|Makefile(\.py)?|license\.txt|LICENSE\.md|NOTICE(\.(txt|md))?|PATCHES|\.patch|\.?php_?cs(\.xml)?|phpunit\.xml|phpdoc\.sh|Rakefile|readme\.txt|README(\.markdown|\.md|\.rst)?|RELEASE-NOTES-?.*|SECURITY(\.md)?|setup-storybook\.sh|StartProfiler\.sample|structure\.txt|styleguide\.md|TODO|UPGRADE(\.md)?|version|resources/lib/jquery\.i18n/CREDITS)$' | xargs /bin/rm -f

# Remove unused directories
rm --force --recursive \
	./"$1"/.pipeline \
	./"$1"/docs \
	./"$1"/extensions/AbuseFilter \
	./"$1"/extensions/CategoryTree \
	./"$1"/extensions/Cite/tests \
	./"$1"/extensions/CiteThisPage/tests \
	./"$1"/extensions/CodeEditor \
	./"$1"/extensions/CodeMirror/tests \
	./"$1"/extensions/ConfirmEdit \
	./"$1"/extensions/DiscussionTools \
	./"$1"/extensions/Echo \
	./"$1"/extensions/Gadgets \
	./"$1"/extensions/ImageMap \
	./"$1"/extensions/InputBox \
	./"$1"/extensions/intersection/tests \
	./"$1"/extensions/Interwiki \
	./"$1"/extensions/Linter \
	./"$1"/extensions/LoginNotify \
	./"$1"/extensions/Math \
	./"$1"/extensions/MultimediaViewer \
	./"$1"/extensions/Nuke \
	./"$1"/extensions/OATHAuth \
	./"$1"/extensions/PageImages \
	./"$1"/extensions/ParserFunctions/tests \
	./"$1"/extensions/PdfHandler \
	./"$1"/extensions/Poem/tests \
	./"$1"/extensions/ReplaceText \
	./"$1"/extensions/Scribunto \
	./"$1"/extensions/SecureLinkFixer \
	./"$1"/extensions/SpamBlacklist \
	./"$1"/extensions/SyntaxHighlight_GeSHi \
	./"$1"/extensions/TemplateData \
	./"$1"/extensions/TextExtracts \
	./"$1"/extensions/Thanks \
	./"$1"/extensions/TitleBlacklist \
	./"$1"/extensions/VisualEditor \
	./"$1"/extensions/WikiEditor/tests \
	./"$1"/languages/data/grammarTransformations/ \
	./"$1"/mw-config/overrides \
	./"$1"/resources/lib/jquery.i18n/src/languages \
	./"$1"/skins/MinervaNeue \
	./"$1"/skins/MonoBook \
	./"$1"/skins/Timeless \
	./"$1"/skins/Vector/dev-scripts/ \
	./"$1"/skins/Vector/tests/ \
	./"$1"/tests \
	./"$1"/vendor/liuggio/statsd-php-client/tests \
	./"$1"/vendor/mck89/peast/doc \
	./"$1"/vendor/pear/console_getopt/tests \
	./"$1"/vendor/pear/net_url2/docs \
	./"$1"/vendor/pear/net_url2/tests \
	./"$1"/vendor/psr/http-message/docs \
	./"$1"/vendor/psr/log/Psr/Log/Test \
	./"$1"/vendor/wikimedia/at-ease/doc \
	./"$1"/vendor/wikimedia/ip-utils/benchmarks \
	./"$1"/vendor/wikimedia/parsoid/tests/ \
	./"$1"/vendor/wikimedia/shellbox/build

