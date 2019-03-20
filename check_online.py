#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time : 19-3-19 下午5:39
# @Author : puxu
# @File : check_online.py
# @Software: PyCharm

import xlwt
# from subprocess import PIPE, Popen
import paramiko
import time

''' 
用于日常线上服务器巡检，结果生成excel，表格格式可以运行后查看。
'''


def set_style(name, height, bold=False):
    style = xlwt.XFStyle()  # 初始化样式
    font = xlwt.Font()  # 为样式创建字体
    font.name = name  # 'Times New Roman'
    font.bold = bold
    font.color_index = 4
    font.height = height
    style.font = font

    borders = xlwt.Borders()  # 边框
    borders.left = 1
    borders.right = 1
    borders.top = 1
    borders.bottom = 1
    borders.bottom_colour = 0x3A
    style.borders = borders

    alignment = xlwt.Alignment()  # 居中
    alignment.horz = xlwt.Alignment.HORZ_CENTER  # 水平方向
    alignment.vert = xlwt.Alignment.VERT_CENTER  # 垂直方向
    alignment.wrap = 1
    style.alignment = alignment

    return style


def make_result(command, ip):
    try:

        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(ip, 22, '', '', timeout=3)

        for cmd in command:
            stdin, stdout, stderr = ssh.exec_command(cmd, timeout=110)
            str = stdout.readlines()
            out = ''.join(str)
            # out = unicode(str, "utf8")
            # print out
            result.append(out)
        ssh.close()

        # result = []
        # sum = 0
        # while sum < len(ips):
        #     for cmd in command:
        #         p = Popen(cmd, shell=True, stdin=PIPE, stdout=PIPE)
        #         out = p.stdout.read()
        #         out = unicode(out, "utf8")
        #         result.append(out)
        #         # print cmd
        #         # print result
        #     sum += 1
        #
        #
        return result
    except Exception as e:
        print "Erro: %s run fail, %s" % (ip, e)
        return None


# 写excel
def write_excel():
    f = xlwt.Workbook()  # 创建工作簿

    ''' 
    创建第一个sheet: 
      sheet1 行列宽高设置
    '''
    sheet1 = f.add_sheet(u'sheet1', cell_overwrite_ok=True)  # 创建sheet
    sheet1.col(0).width = 256 * 20
    sheet1.col(3).width = 500 * 40
    tall_style = xlwt.easyxf('font:height 3200')
    second_row = sheet1.row(1)
    second_row.set_style(tall_style)

    row0 = [u'IP', u'命令', u'巡检项', u'巡检值']  # 第一行
    ips = [u'192.168.198.129', u'192.168.198.129']  # 第一列
    cmds = [u'top', u'free -m', u'df -h']  # 第二列
    items = [u'cpu占用', u'内存占用', u'硬盘占用']  # 第三列
    command = [u'top -bn 1 -i -c', u'free -m', u'df -h']

    try:
        for ip in ips:
            results = make_result(command, ip)  # 第四列
    except:
        results = []

    # 生成第一行
    for i in range(0, len(row0)):
        sheet1.write(0, i, row0[i], set_style('Times New Roman', 220, True))

    # 第一列
    line, row = 1, 0
    while line < 3 * len(ips) and row < len(ips):
        sheet1.write_merge(line, line + 2, 0, 0, ips[row], set_style('Arial', 220, True))
        line += 3
        row += 1

    # 生成第二列
    line = 0
    while line < 3 * len(ips):
        for row in range(0, len(cmds)):
            sheet1.write(row + line + 1, 1, cmds[row], set_style('Arial', 220))
        line += 3

    # 生成第三列
    line = 0
    while line < 3 * len(ips):
        for row in range(0, len(cmds)):
            sheet1.write(row + line + 1, 2, items[row], set_style('Arial', 220))
        line += 3

    # 生成第四列
    line = 0
    # while line < 3 * len(ips):
    # for row in range(0, len(cmds)):
    for row in range(0, 3 * len(ips)):
        sheet1.write(row + line + 1, 3, results[row], set_style('Arial', 220))
    # line += 3

    today = time.strftime("%Y%m%d", time.localtime())
    file_exc = '/home/puxu//test/xunjian' + today + '.xlsx'
    f.save(file_exc)  # 保存文件

    print "ip list : %s run check success!" % (ips)


if __name__ == '__main__':
    result = []
    write_excel()
