# 本部分是关于存储体系部分的设计
## v1.0（参见doc下设计文档）

### 主要功能

* hanming code （SEC-DED）
* I-Cache：直接映射
* D-Cache：两路组相连
* L2-Cache：两路组相连
* Memory

### 想法

```
初始想法只是在提供一个支持四取指的I-Cache和支持不对齐数据访问的D-Cache
和一个双端口的L2-Cache
对RAM进行SEC-DED编码
```

```
1.后来重新温习了一下关于hanming纠错码的原理,算是在老师上课教学的基础上去进一步探究了一下"所以然":
	从hanming code的公式 -> hanming距离 -> hanming code原理
	此部分理解存于"doc/设计文档v1.0"	
2.后来又去看了下段师姐给的建议文档,看见了Hasio对hanming码进行了优化变得更加适合硬件实现
	就是通过Odd-weight-column SEC-DED Code去均衡门的关键路径的技术优化	
3.在基本掌握了相关编码逻辑之后尝试初步使用Verilog进行编码实现Hasio code的编码器以及验证器
	仅一天时间就完成了通用模块的编写以及通过testbanch验证......
	因为使用了Verilog中系统函数,所以编写的通用模块适用于任意位宽的数据,所以基本上关于存储体系的SEC-DED逻辑就啪叽一下结束了......
	然后因为我目前只分工存储体系部分就霎时间感觉毕设还没开始就结束了.......
	因为对于cache体系的组织部分我之前的学习过程中都实现过,较为简单,所以关于这方面就可以很快的去解决实现编码逻辑....毕设结束了?????????
4.在2023/12/11日时和19团队探讨了下相关实现问题,润民师兄针对我所负责部分提出了一个问题:
	既然我打算在存储体系实现存储器,那么为了贴近真实计算机,那么必须实现总线协议和响应存储控制器!!!

由此诞生了v2.0
```

## v2.0(目前)(参见doc目录下详细文档)

### 主要功能

* v1.0的基础功能
* 存储体系内部基于AXI1.0协议总线交互
* 存储控制器设计
* 支持初始化功能(尽可能减少强制不命中)

### 想法

```
时间:2023/12/13晚20:00

1.已经初步看完AXI1.0总线协议手册,关于在本次设计之中的可行性分析和相关逻辑都以基本验证自洽
2.对于时序数据流和控制流动路径已基本梳理完成,且具有可行性以及可实现性
	(而且我也觉得基于一个约定俗成的协议规范实现对应功能也较为简单,基本知识框架体系已在草纸上初步实现)
3.明天开始进行设计文档的整理编写工作
4.设计文档弄出来就差不多开始进行代码的编写工作了
	因为我负责的存储体系部分与其他人的负责部分相对独立,所以只要支持对应上层交互接口,内部实现我可以很快地进行
	而且读完协议手册之后我觉得我较大概率想法v2.0的代码编写工作可以在本月完成
	文档v2.0整理完成(doc目录下)
```

### v2.1(见doc下v2.1详细文档设计)

```
修改了关于存储体系共享总线的模式,改为双总线结构
一条总线用于I-Cache/D-Cache/L2-Cache交互
一条总线用于L2-Cache与memory交互
```

## v3.0(时间富裕的前提下)

+ 基于AXI1.0的总线可以较为简单的实现I-Cache预取(连续取相邻地址)
+ D-Cache预取
+ 更加复杂的替换算法
+ 支持指令自修改
+ TLB
+ 虚存技术
+ ....





---FMRT20霍志朋

---写于2023/12/13  20:15