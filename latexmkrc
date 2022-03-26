# vim: ft=perl

# Imports vars like `$OSNAME` instead of perl punctuation names like `$^O`.
# See `man perlvar`
use English;

$pdflatex = 'xelatex -interaction=nonstopmode -halt-on-error -synctex=1 %O %S';
$pdf_mode = 1;
$postscript_mode = 0;
$dvi_mode = 0;
$preview_continuous_mode = 1;

if($OSNAME =~ "MSWin32") {
  $pdf_previewer = '"/mnt/c/Program Files/SumatraPDF/SumatraPDF.exe" %O %S';
} elsif($OSNAME =~ "darwin") {
  # Default previewer is fine.
} elsif($OSNAME =~ "linux") {
  $pdf_previewer = 'qpdfview --unique %O %S';
}
