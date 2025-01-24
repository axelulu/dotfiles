
echo "121212-------------"

processName="menus.sh"
processNum=`ps -aef |grep "${processName}" | wc -l`

echo $processNum

if [ "${processNum}" -gt "3" ]; then
  echo "已经有脚本在运行，本脚本不支持多实例运行${processNum}"
  exit 1
fi

"$CONFIG_DIR/helpers/menus/bin/menus" -s $1
