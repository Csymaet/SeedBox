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

check_role() {
	FILE="$1"
	echo "=== $FILE ==="

	KNOWLEDGE_NUMS=$(grep "^知识卡片：" "$FILE" | sed 's/知识卡片：//')

	if [ -z "$KNOWLEDGE_NUMS" ]; then
		echo "  无关联知识卡片"
		return
	fi

	for NUM in $KNOWLEDGE_NUMS; do
		CARD=$(find "$SEED_BOX/002-知识卡片" -name "${NUM}-*.md" 2>/dev/null | head -1)
		if [ -f "$CARD" ]; then
			echo "  ✓ $NUM"
		else
			echo "  ✗ $NUM"
		fi
	done
}

if [ -z "$ROLE_FILE" ]; then
	echo "检查所有角色卡片..."
	echo ""
	find "$SEED_BOX/001-角色卡片" -name "*.md" -type f | while read CARD; do
		check_role "$CARD"
		echo ""
	done
else
	# 处理绝对路径和相对路径
	if [[ "$ROLE_FILE" == /* ]]; then
		# 绝对路径，直接使用
		ROLE_PATH="$ROLE_FILE"
	else
		# 相对路径，拼接 SEED_BOX
		ROLE_PATH="$SEED_BOX/$ROLE_FILE"
	fi

	if [ ! -f "$ROLE_PATH" ]; then
		echo "错误: 找不到 $ROLE_PATH"
		exit 1
	fi
	check_role "$ROLE_PATH"
fi
