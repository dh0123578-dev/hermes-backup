---
name: auto-quotation
description: 自动报价单系统 — 韩总说"报价"时，查询产品库和客户库，生成专业 PDF 报价单 + 图片，发到微信上
---

# 报价单自动生成系统

## 数据库位置
- `~/报价系统/quotation.db` — SQLite 数据库
- `~/报价系统/generate_quotation.py` — 报价单生成脚本

## 数据库表结构

### products
| 字段 | 类型 | 说明 |
|------|------|------|
| model | TEXT | 产品型号（唯一） |
| name | TEXT | 产品名称 |
| unit | TEXT | 单位（默认"台"） |
| price | REAL | 单价 |
| remark | TEXT | 备注 |

### customers
| 字段 | 类型 | 说明 |
|------|------|------|
| name | TEXT | 客户名称（唯一） |
| contact | TEXT | 联系方式 |
| discount | REAL | 折扣率（0.95=95折） |
| remark | TEXT | 备注 |

## 技能触发条件
用户说"报价"相关的指令时，执行以下流程。

## 工作流程

### 1. 解析用户意图
用户可能说：
- "给XX公司报价10台A、5台B" → 直接报价
- "帮我查一下XX产品价格" → 先查后报价
- "添加产品XXX..." → 维护数据库
- "看看有什么产品" → 列出产品

### 2. 查询数据库
```python
# 查产品
python3 -c "
import sqlite3
db = sqlite3.connect('$HOME/报价系统/quotation.db')
for r in db.execute('SELECT model, name, price, unit FROM products ORDER BY model'):
    print(f'{r[0]:12s}  {r[1]:20s}  ¥{r[2]:>8.2f}/{r[3]}')
db.close()
"

# 查客户
python3 -c "
import sqlite3
db = sqlite3.connect('$HOME/报价系统/quotation.db')
for r in db.execute('SELECT * FROM customers'):
    disc = f\"{int((1-r[3])*100)}%OFF\" if r[3] < 1 else '无折扣'
    print(f'{r[1]:20s}  {r[2]:15s}  {disc}')
db.close()
"
```

### 3. 生成报价单
```bash
cd ~/报价系统
python3 generate_quotation.py "<客户名>" <型号1>=<数量1> <型号2>=<数量2> ...
```

### 4. 发送给用户
脚本输出 `===RESULT===` 后跟随：
- PDF_PATH — PDF 文件路径
- IMG_PATH — 图片文件路径
- TOTAL — 总金额

**发送方式**：在回复中包含 `MEDIA:<IMG_PATH>` 发送图片到微信，同时说明金额明细。如有需要可同时发送 MEDIA:<PDF_PATH>。

### 5. 数据维护
**添加产品**：
```python
python3 -c "
import sqlite3
db = sqlite3.connect('$HOME/报价系统/quotation.db')
db.execute('INSERT INTO products (model, name, price, unit, remark) VALUES (?,?,?,?,?)',
           ('型号', '名称', 单价, '台', '备注'))
db.commit()
db.close()
print('✅ 添加成功')
"
```

**添加客户**：
```python
python3 -c "
import sqlite3
db = sqlite3.connect('$HOME/报价系统/quotation.db')
db.execute('INSERT INTO customers (name, contact, discount, remark) VALUES (?,?,?,?)',
           ('客户名', '联系方式', 0.95, '备注'))
db.commit()
db.close()
print('✅ 添加成功')
"
```

## 注意事项
- 客户不存在时，脚本会自动提示但继续（使用无折扣）
- 产品型号不存在时脚本报错退出，需先添加产品
- 图片用 `pdftoppm` 从 PDF 转换
- 字体用文泉驿（wqy-zenhei）
