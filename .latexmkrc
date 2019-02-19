# vim: ft=perl
$pdflatex = 'xelatex %O %S';
$pdflatex_silent_switch = "-interaction=nonstopmode -halt-on-error";
$pdf_mode = 1;
$postscript_mode = 0;
$dvi_mode = 0;
$pdf_previewer = '"C:/Program Files/SumatraPDF/SumatraPDF.exe" %O %S';
$preview_continuous_mode = 1;
$aux_dir = 'extra';

sub run_chktex {
  my $name = shift;
  my $chktex_opts = "";
  if ( $silent ) {
    $chktex_opts = "-q -v0";
  }
  system "chktex $chktex_opts $name";
}

sub run_lacheck {
  my $name = shift;
  system "lacheck $name";
}

sub mv_fls {
  Run_subst("mv %B.fls $aux_dir");
}

sub lint {
  my $fname = shift;
  # lint
  run_lacheck($fname);
  run_chktex($fname);
  system(@_);
  mv_fls();
}

$pdflatex = "internal lint %S $pdflatex";
