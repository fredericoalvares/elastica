source $SCRIPTS_PATH/hashtable.hsh
#config_metrics
metric='out_load_ok'
num_col='3'
ylabel="number of succeeded requests"
hput num_col "$metric" "$num_col"
hput ylabel "$metric" "$ylabel"

metric='out_load_ko'
num_col='4'
ylabel="number of failed requests"
hput num_col "$metric" "$num_col"
hput ylabel "$metric" "$ylabel"

metric='size_infra'
num_col='5'
ylabel="Infrastructure's size (number of vms)"
hput num_col "$metric" "$num_col"
hput ylabel "$metric" "$ylabel"

metric='app_level'
num_col='6'
ylabel="Application level"
hput num_col "$metric" "$num_col"
hput ylabel "$metric" "$ylabel"

metric='mean_responsetime'
num_col='7'
ylabel="Mean response time (ms)"
hput num_col "$metric" "$num_col"
hput ylabel "$metric" "$ylabel"

