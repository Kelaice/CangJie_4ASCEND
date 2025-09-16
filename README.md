## Cangjie_4ASCEND
仅供学习交流使用

如需修改，请在原有代码的结构、变量名和命名规则下修改，确保一致性

src文件夹请放在entry/src/main/cangjie模块下使用，在那之前，请务必备份好您原本的文件，并删除cangjie文件夹下原本的三个.cj文件

---
#### 2025.9.16更新
初次可运行，升华状态的棋子暂时没有可视显示

#### 2025.9.17更新
优化了文件和代码结构
- 现在testboard组件和playerstate组件被分离到src/game_body/draw.cj中
- 桥接显示层和逻辑层的运算函数被分离到src/game_body/run.cj中
