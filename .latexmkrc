# vim: ft=perl
$pdflatex = 'xelatex -interaction=nonstopmode -halt-on-error -synctex=1 %O %S';
$pdf_mode = 1;
$postscript_mode = 0;
$dvi_mode = 0;
if($OSNAME =~ "MSWin32") {
  $pdf_previewer = '"/mnt/c/Program Files/SumatraPDF/SumatraPDF.exe" %O %S';
} else {
  $pdf_previewer = '"evince" %O %S';
}
$preview_continuous_mode = 1;
