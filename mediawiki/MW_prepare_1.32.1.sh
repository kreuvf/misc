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
# Effect
# 15,094 items (144.1 MB) -> 5,756 items (32.4 MB)
#
# WARNING: Most likely, this script is not suitable for you out of the box.
# Use at your own discretion after carefully checking what this script
# does/intends to do.
#
# Author: Steven 'Kreuvf' Koenig
# Created: 2019-05-19
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
find ./"$1"/includes/installer/i18n/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/includes/api/i18n/ -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/resources/lib/ooui/i18n -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/resources/lib/jquery.ui/i18n -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/resources/lib/jquery.i18n -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/resources/lib/jquery.i18n/src -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/resources/lib/jquery.i18n/src/languages -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/skins/Vector/i18n -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/extensions/Cite/i18n -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/extensions/Cite/modules/ve-cite/i18n -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/extensions/CodeMirror/i18n -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/extensions/WikiEditor/i18n -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/extensions/Poem/i18n -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/extensions/ParserFunctions/i18n -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/extensions/CiteThisPage/i18n -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/vendor/oojs/oojs-ui/i18n -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/languages/classes -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/languages/i18n -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/languages/messages -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/resources/lib/moment/locale -type f >> MW_prepare_i18n_deletion.lst

# Files in non-standard extensions
find ./"$1"/extensions/intersection/i18n -type f >> MW_prepare_i18n_deletion.lst
find ./"$1"/extensions/Maintenance/i18n -type f >> MW_prepare_i18n_deletion.lst

# Remove all non-translation files
sed -i -r -e '/(php|js(on)?)$/!d' MW_prepare_i18n_deletion.lst
sed -i -r -e '/\/jquery\.i18n(\.[a-zA-Z]+)*\.js$/d' MW_prepare_i18n_deletion.lst

# Remove all de and en language files (we want to save them <3)
sed -i -r -e '/(de|en)([-_][-_a-zA-Z]+)?\.js(on)?$/d' MW_prepare_i18n_deletion.lst
sed -i -r -e '/LanguageEn\.php$/d' MW_prepare_i18n_deletion.lst
sed -i -r -e '/Messages(De|En)\.php$/d' MW_prepare_i18n_deletion.lst

# Quote strings
sed -i -r -e 's/^(.*)$/'\''\1'\''/' MW_prepare_i18n_deletion.lst

# Remove all the crap
xargs --interactive --arg-file=MW_prepare_i18n_deletion.lst /bin/rm -f

# Remove intermediary file, thank you file
rm MW_prepare_i18n_deletion.lst

# Remove unused directories
rm --force --recursive \
	./"$1"/docs \
	./"$1"/extensions/CategoryTree \
	./"$1"/extensions/Cite/tests \
	./"$1"/extensions/CiteThisPage/tests \
	./"$1"/extensions/CodeEditor \
	./"$1"/extensions/CodeMirror/tests \
	./"$1"/extensions/ConfirmEdit \
	./"$1"/extensions/Gadgets \
	./"$1"/extensions/ImageMap \
	./"$1"/extensions/InputBox \
	./"$1"/extensions/intersection/tests \
	./"$1"/extensions/Interwiki \
	./"$1"/extensions/LocalisationUpdate \
	./"$1"/extensions/MultimediaViewer \
	./"$1"/extensions/Nuke \
	./"$1"/extensions/OATHAuth \
	./"$1"/extensions/ParserFunctions/tests \
	./"$1"/extensions/PdfHandler \
	./"$1"/extensions/Poem/tests \
	./"$1"/extensions/Renameuser \
	./"$1"/extensions/ReplaceText \
	./"$1"/extensions/SpamBlacklist \
	./"$1"/extensions/SyntaxHighlight_GeSHi \
	./"$1"/extensions/TitleBlacklist \
	./"$1"/extensions/WikiEditor/tests \
	./"$1"/mw-config/overrides \
	./"$1"/resources/lib/jquery.i18n/src/languages \
	./"$1"/skins/MonoBook \
	./"$1"/skins/Timeless \
	./"$1"/tests \
	./"$1"/vendor/pear/net_smtp/docs \
	./"$1"/vendor/pear/net_smtp/tests

# Remove empty (and unused) directories; these will not show up in Git (no files inside)
rm --force \
	./"$1"/mw-config/overrides \
	./"$1"/resources/lib/jquery.i18n/src/languages

# Gather files unnecessary for just running the wiki
find ./"$1"/ -type f -regextype posix-extended -regex '.*(\.editorconfig|\.(es|style)lintrc\.json|\.git(ignore|review)|\.scrutinizer\.yml|\.stylelintrc|(APACHE|GPL|MIT)?-?LICENSE-?(2\.0|MIT)?(\.txt)?|AUTHORS(\.txt)?|changelog\.txt|CHANGELOG(\.md)?|CHANGES\.md|CODE_OF_CONDUCT\.md|composer\.local\.json-sample|CONTRIBUTING\.md|COPYING(\.txt)?|dependencies\.txt|Doxyfile|errors\.md|example_debug\.png|FAQ|formats\.md|Gemfile\.lock|gitinfo\.json|Gruntfile\.js|History(\.md)?|HISTORY(\.md)?|INSTALL|Makefile(\.py)?|license\.txt|NOTICE\.txt|PATCHES|\.?php_?cs(\.xml)?|phpdoc\.sh|Rakefile|readme\.txt|README(\.md|\.rst)?|RELEASE-NOTES-?.*|SECURITY|StartProfiler\.sample|structure\.txt|styleguide\.md|UPGRADE(\.md)?|version|resources/lib/jquery\.i18n/CREDITS)$' | xargs --interactive /bin/rm -f

