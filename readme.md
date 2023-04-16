# Trabalho de PACDI

## install

É preciso por o dataset do moodle em `data/`

```powershell
scoop install git gh tectonic watchexec
gh repo clone notPlancha\pbd
R.exe -e 'install.packages("jetpack")'
R.exe -e 'jetpack::install()'
R.exe -e 'IRkernel::installspec(displayname="IR PACD", name="ir_pacd", rprofile=here::here(".Rprofile"))
pip install nbdev
nbdev_install_hooks
```
