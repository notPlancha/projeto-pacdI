# Trabalho de PACDI

## install

É preciso por o dataset do moodle em `data/`

```powershell
Remove-Alias R -Force
scoop install git gh tectonic watchexec
gh repo clone notPlancha/projeto-pacdI
cd .\projeto-pacdI
R -e "install.packages('devtools')" # ordem de aspas importante
R -e "devtools::install_deps()"
R -e "IRkernel::installspec(displayname='IR PACD', name='ir_pacd', rprofile=here::here('.Rprofile'))"
pip install nbdev jupytext
nbdev_install_hooks
```
Depois de ter o dataset em `data/`, este pode ser passado para .parquet com `script/toParquet.R` (sem mudanças na base de dados)