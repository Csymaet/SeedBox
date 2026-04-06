#!/bin/bash
ROLE_FILE="$1"

find_seed_box() {
	DIR="$(dirname "$0")"
	while [ "$DIR" != "/" ]; do
		if [ -d "$DIR/001-角色卡片" ] && [ -d "$DIR/002-知识卡片" ]; then
			echo "$DIR"
			return 0
		fi
		DIR="$(dirname "$DIR")"
	done
	echo "错误: 未找到 seed-box 根目录" >&2
	return 1
}

SEED_BOX="$(find_seed_box)"

if [ -z "$ROLE_FILE" ]; then
	echo "用法: $0 <角色卡片路径>"
	exit 1
fi

# 1. 输出角色卡片内容
if [ -f "$SEED_BOX/$ROLE_FILE" ]; then
	echo "=== 角色卡片 ==="
	cat "$SEED_BOX/$ROLE_FILE"
	echo ""
else
	echo "错误: 找不到角色卡片 $SEED_BOX/$ROLE_FILE"
	exit 1
fi

# 2. 提取知识卡片编号
echo "=== 关联知识卡片 ==="
KNOWLEDGE_NUMS=$(grep "^知识卡片：" "$SEED_BOX/$ROLE_FILE" | sed 's/知识卡片：//')

if [ -z "$KNOWLEDGE_NUMS" ]; then
	echo "（无关联知识卡片）"
	exit 0
fi

# 3. 输出每个知识卡片内容
for NUM in $KNOWLEDGE_NUMS; do
	# 查找对应的知识卡片文件
	CARD=$(find "$SEED_BOX/002-知识卡片" -name "${NUM}-*.md" 2>/dev/null | head -1)
	if [ -f "$CARD" ]; then
		echo ""
		echo "--- $CARD ---"
		cat "$CARD"
	else
		echo "（未找到知识卡片: $NUM）"
	fi
done
