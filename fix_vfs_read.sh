#!/bin/bash

# Find the exact line number of "ssize_t vfs_read"
LINE=$(grep -n "^ssize_t vfs_read" fs/read_write.c | head -1 | cut -d: -f1)

if [ -z "$LINE" ]; then
    echo "Error: Cannot find vfs_read function"
    exit 1
fi

echo "Found vfs_read at line $LINE"

# Add extern declarations before the function
BEFORE_LINE=$LINE
sed -i "${BEFORE_LINE}i\\
#ifdef CONFIG_KSU\\
extern bool ksu_vfs_read_hook __read_mostly;\\
extern int ksu_handle_vfs_read(struct file **file_ptr, char __user **buf_ptr,\\
\\t\\t\\tsize_t *count_ptr, loff_t **pos);\\
#endif" fs/read_write.c

# Find "ssize_t ret;" inside vfs_read and add hook after it
# Re-get line number as it shifted
LINE=$(grep -n "^ssize_t vfs_read" fs/read_write.c | head -1 | cut -d: -f1)
INSIDE_LINE=$((LINE + 3))  # Approximately where "ssize_t ret;" should be

sed -i "${INSIDE_LINE}a\\
\\
#ifdef CONFIG_KSU\\
\\tif (unlikely(ksu_vfs_read_hook))\\
\\t\\tksu_handle_vfs_read(\&file, \&buf, \&count, \&pos);\\
#endif" fs/read_write.c

echo "Hook applied!"
sed -n "$((LINE - 2)),$((LINE + 15))p" fs/read_write.c
