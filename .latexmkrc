# vim:ft=perl

$pdflatex = 'xelatex -interaction=nonstopmode -halt-on-error %O %S';
$pdf_mode = 1;
$postscript_mode =0;
$dvi_mode = 0;
$pdf_previewer = 'start "C:/Program Files/SumatraPDF/SumatraPDF.exe" %O %S';
$preview_continuous_mode = 1;
$aux_dir = 'extra';

sub run_chktex {
  my $name = shift;
  if ( $silent ) {
    system "chktex -q -v0 $name";
  }
  else {
    system "chktex $name";
  };
}

sub run_lacheck {
  my $name = shift;
  system "lacheck $name";
}

sub lint {
  my $fname = shift;
  # lint
  run_lacheck $fname;
  run_chktex $fname;
  system(@_);
}

$pdflatex = "internal lint %S $pdflatex";
