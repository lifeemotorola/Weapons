#!/usr/bin/env python3
"""
VirtualOS Complete Documentation Generator
Generates a professional PDF documentation file
"""

from reportlab.lib.pagesizes import A4, letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch, cm
from reportlab.lib.colors import (
    HexColor, black, white, gray
)
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle,
    PageBreak, HRFlowable, KeepTogether, Preformatted
)
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT, TA_JUSTIFY
from reportlab.platypus.flowables import Flowable
from reportlab.lib import colors
from reportlab.pdfgen import canvas
from reportlab.platypus import BaseDocTemplate, Frame, PageTemplate
import datetime
import os
import sys

# ============================================================
# COLOR PALETTE
# ============================================================
COLOR_PRIMARY       = HexColor('#1A1A2E')
COLOR_SECONDARY     = HexColor('#16213E')
COLOR_ACCENT        = HexColor('#0F3460')
COLOR_HIGHLIGHT     = HexColor('#E94560')
COLOR_SUCCESS       = HexColor('#00B074')
COLOR_WARNING       = HexColor('#F5A623')
COLOR_INFO          = HexColor('#4A90D9')
COLOR_TERMINAL_BG   = HexColor('#0D1117')
COLOR_TERMINAL_TEXT = HexColor('#C9D1D9')
COLOR_TERMINAL_GRN  = HexColor('#3FB950')
COLOR_TERMINAL_YLW  = HexColor('#D29922')
COLOR_TERMINAL_BLU  = HexColor('#58A6FF')
COLOR_LIGHT_BG      = HexColor('#F6F8FA')
COLOR_BORDER        = HexColor('#D0D7DE')
COLOR_TEXT_DARK     = HexColor('#1F2328')
COLOR_TEXT_MED      = HexColor('#656D76')
COLOR_TEXT_LIGHT    = HexColor('#FFFFFF')
COLOR_TABLE_HEADER  = HexColor('#1A1A2E')
COLOR_TABLE_ROW1    = HexColor('#F6F8FA')
COLOR_TABLE_ROW2    = HexColor('#FFFFFF')
COLOR_CODE_BG       = HexColor('#161B22')
COLOR_SECTION_LINE  = HexColor('#E94560')
COLOR_TOC_BG        = HexColor('#EEF2FF')

PAGE_WIDTH, PAGE_HEIGHT = A4

# ============================================================
# CUSTOM FLOWABLES
# ============================================================

class ColoredHRule(Flowable):
    def __init__(self, width, color, thickness=1):
        Flowable.__init__(self)
        self.width = width
        self.color = color
        self.thickness = thickness
        self.height = thickness + 2

    def draw(self):
        self.canv.setStrokeColor(self.color)
        self.canv.setLineWidth(self.thickness)
        self.canv.line(0, self.thickness / 2, self.width, self.thickness / 2)


class GradientRect(Flowable):
    def __init__(self, width, height, color1, color2=None, radius=4):
        Flowable.__init__(self)
        self.width = width
        self.height = height
        self.color1 = color1
        self.color2 = color2 or color1
        self.radius = radius

    def draw(self):
        self.canv.setFillColor(self.color1)
        self.canv.roundRect(0, 0, self.width, self.height,
                            self.radius, fill=1, stroke=0)


class SectionHeader(Flowable):
    def __init__(self, number, title, width, color=None):
        Flowable.__init__(self)
        self.number = number
        self.title = title
        self.width = width
        self.color = color or COLOR_PRIMARY
        self.height = 42

    def draw(self):
        c = self.canv
        # Background bar
        c.setFillColor(self.color)
        c.roundRect(0, 0, self.width, self.height, 6, fill=1, stroke=0)
        # Number badge
        c.setFillColor(COLOR_HIGHLIGHT)
        c.roundRect(8, 7, 28, 28, 4, fill=1, stroke=0)
        c.setFillColor(white)
        c.setFont('Helvetica-Bold', 14)
        c.drawCentredString(22, 14, str(self.number))
        # Title text
        c.setFillColor(white)
        c.setFont('Helvetica-Bold', 16)
        c.drawString(46, 14, self.title)


class InfoBox(Flowable):
    def __init__(self, label, text, width, bg_color, border_color, text_color=None):
        Flowable.__init__(self)
        self.label = label
        self.text = text
        self.width = width
        self.bg_color = bg_color
        self.border_color = border_color
        self.text_color = text_color or COLOR_TEXT_DARK
        self.height = 52

    def draw(self):
        c = self.canv
        c.setFillColor(self.bg_color)
        c.roundRect(0, 0, self.width, self.height, 5, fill=1, stroke=0)
        c.setStrokeColor(self.border_color)
        c.setLineWidth(1.5)
        c.roundRect(0, 0, self.width, self.height, 5, fill=0, stroke=1)
        # Left accent
        c.setFillColor(self.border_color)
        c.rect(0, 0, 5, self.height, fill=1, stroke=0)
        c.roundRect(0, 0, 5, self.height, 2, fill=1, stroke=0)
        c.setFillColor(self.border_color)
        c.setFont('Helvetica-Bold', 9)
        c.drawString(14, self.height - 16, self.label)
        c.setFillColor(self.text_color)
        c.setFont('Helvetica', 9)
        # Wrap text
        max_chars = int((self.width - 20) / 5.5)
        words = self.text.split()
        lines = []
        current = ''
        for word in words:
            if len(current) + len(word) + 1 <= max_chars:
                current = (current + ' ' + word).strip()
            else:
                if current:
                    lines.append(current)
                current = word
        if current:
            lines.append(current)
        y = self.height - 30
        for line in lines[:2]:
            c.drawString(14, y, line)
            y -= 13


class TerminalBlock(Flowable):
    def __init__(self, lines, width, title='Terminal'):
        Flowable.__init__(self)
        self.lines = lines if isinstance(lines, list) else lines.split('\n')
        self.width = width
        self.title = title
        self.line_height = 13
        self.padding = 12
        self.title_height = 28
        self.height = (self.title_height + self.padding +
                       len(self.lines) * self.line_height + self.padding)

    def draw(self):
        c = self.canv
        # Outer shadow
        c.setFillColor(HexColor('#000000'))
        c.setFillAlpha(0.15)
        c.roundRect(3, -3, self.width, self.height, 8, fill=1, stroke=0)
        c.setFillAlpha(1.0)
        # Main background
        c.setFillColor(COLOR_TERMINAL_BG)
        c.roundRect(0, 0, self.width, self.height, 8, fill=1, stroke=0)
        # Title bar
        c.setFillColor(HexColor('#21262D'))
        c.roundRect(0, self.height - self.title_height,
                    self.width, self.title_height, 8, fill=1, stroke=0)
        c.rect(0, self.height - self.title_height,
               self.width, self.title_height / 2, fill=1, stroke=0)
        # Traffic lights
        for i, col in enumerate([HexColor('#FF5F57'), HexColor('#FEBC2E'), HexColor('#28C840')]):
            c.setFillColor(col)
            c.circle(16 + i * 18, self.height - 14, 5, fill=1, stroke=0)
        # Title text
        c.setFillColor(HexColor('#8B949E'))
        c.setFont('Helvetica', 9)
        c.drawCentredString(self.width / 2, self.height - 18, self.title)
        # Content lines
        y = self.height - self.title_height - self.padding - self.line_height
        for line in self.lines:
            if y < self.padding:
                break
            if line.startswith('$ ') or line.startswith('# '):
                c.setFillColor(COLOR_TERMINAL_GRN)
                c.setFont('Courier-Bold', 8.5)
            elif line.startswith('//') or line.startswith('#!'):
                c.setFillColor(COLOR_TERMINAL_YLW)
                c.setFont('Courier', 8.5)
            elif line.startswith('[') and (']' in line):
                c.setFillColor(COLOR_TERMINAL_BLU)
                c.setFont('Courier', 8.5)
            elif line.startswith('Error') or line.startswith('ERR'):
                c.setFillColor(COLOR_HIGHLIGHT)
                c.setFont('Courier', 8.5)
            else:
                c.setFillColor(COLOR_TERMINAL_TEXT)
                c.setFont('Courier', 8.5)
            # Clip long lines
            safe = line[:95]
            c.drawString(self.padding, y, safe)
            y -= self.line_height


class CommandBadge(Flowable):
    def __init__(self, command, description, width):
        Flowable.__init__(self)
        self.command = command
        self.description = description
        self.width = width
        self.height = 30

    def draw(self):
        c = self.canv
        c.setFillColor(COLOR_LIGHT_BG)
        c.roundRect(0, 0, self.width, self.height, 4, fill=1, stroke=0)
        c.setStrokeColor(COLOR_BORDER)
        c.setLineWidth(0.5)
        c.roundRect(0, 0, self.width, self.height, 4, fill=0, stroke=1)
        # Command
        cmd_w = min(len(self.command) * 7.5 + 16, self.width * 0.35)
        c.setFillColor(COLOR_PRIMARY)
        c.roundRect(6, 5, cmd_w, 20, 3, fill=1, stroke=0)
        c.setFillColor(white)
        c.setFont('Courier-Bold', 9)
        c.drawString(10, 11, self.command[:int(cmd_w / 7)])
        # Description
        c.setFillColor(COLOR_TEXT_MED)
        c.setFont('Helvetica', 9)
        max_ch = int((self.width - cmd_w - 24) / 5.5)
        desc = self.description[:max_ch]
        c.drawString(cmd_w + 14, 11, desc)


class CoverPage(Flowable):
    def __init__(self, width, height):
        Flowable.__init__(self)
        self.width = width
        self.height = height

    def draw(self):
        c = self.canv
        # Deep background
        c.setFillColor(COLOR_PRIMARY)
        c.rect(0, 0, self.width, self.height, fill=1, stroke=0)
        # Decorative circles
        for x, y, r, alpha in [
            (self.width * 0.85, self.height * 0.75, 200, 0.06),
            (self.width * 0.1,  self.height * 0.25, 150, 0.05),
            (self.width * 0.5,  self.height * 0.5,  300, 0.03),
            (self.width * 0.9,  self.height * 0.2,  100, 0.07),
        ]:
            c.setFillColor(COLOR_HIGHLIGHT)
            c.setFillAlpha(alpha)
            c.circle(x, y, r, fill=1, stroke=0)
        c.setFillAlpha(1.0)
        # Grid lines
        c.setStrokeColor(white)
        c.setStrokeAlpha(0.04)
        c.setLineWidth(0.5)
        for i in range(0, int(self.width), 30):
            c.line(i, 0, i, self.height)
        for j in range(0, int(self.height), 30):
            c.line(0, j, self.width, j)
        c.setStrokeAlpha(1.0)
        # Top accent bar
        c.setFillColor(COLOR_HIGHLIGHT)
        c.rect(0, self.height - 6, self.width, 6, fill=1, stroke=0)
        # Logo area
        logo_y = self.height * 0.62
        c.setFillColor(HexColor('#0F3460'))
        c.roundRect(self.width * 0.1, logo_y - 10,
                    self.width * 0.8, 180, 12, fill=1, stroke=0)
        c.setStrokeColor(COLOR_HIGHLIGHT)
        c.setLineWidth(1.5)
        c.roundRect(self.width * 0.1, logo_y - 10,
                    self.width * 0.8, 180, 12, fill=0, stroke=1)
        # ASCII Logo text
        c.setFillColor(COLOR_TERMINAL_GRN)
        c.setFont('Courier-Bold', 9)
        logo_lines = [
            '██╗   ██╗██╗██████╗ ████████╗██╗   ██╗ █████╗ ██╗',
            '██║   ██║██║██╔══██╗╚══██╔══╝██║   ██║██╔══██╗██║',
            '██║   ██║██║██████╔╝   ██║   ██║   ██║███████║██║',
            '╚██╗ ██╔╝██║██╔══██╗   ██║   ██║   ██║██╔══██║██║',
            ' ╚████╔╝ ██║██║  ██║   ██║   ╚██████╔╝██║  ██║███████╗',
            '  ╚═══╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝',
        ]
        start_y = logo_y + 145
        for line in logo_lines:
            c.drawCentredString(self.width / 2, start_y, line)
            start_y -= 14
        # OS badge
        c.setFillColor(COLOR_HIGHLIGHT)
        c.roundRect(self.width / 2 - 45, logo_y + 5, 90, 28, 6, fill=1, stroke=0)
        c.setFillColor(white)
        c.setFont('Helvetica-Bold', 14)
        c.drawCentredString(self.width / 2, logo_y + 13, 'OS  v1.0.0')
        # Main title
        c.setFillColor(white)
        c.setFont('Helvetica-Bold', 28)
        c.drawCentredString(self.width / 2, self.height * 0.52,
                            'Complete Documentation')
        # Subtitle
        c.setFillColor(HexColor('#8B949E'))
        c.setFont('Helvetica', 13)
        c.drawCentredString(self.width / 2, self.height * 0.47,
                            'Virtual Operating System for Termux')
        # Divider
        c.setStrokeColor(COLOR_HIGHLIGHT)
        c.setLineWidth(1)
        c.line(self.width * 0.2, self.height * 0.44,
               self.width * 0.8, self.height * 0.44)
        # Info pills
        info_items = [
            ('Platform', 'Termux / Android'),
            ('Language', 'Bash Shell'),
            ('Files', 'Single File'),
            ('License', 'MIT'),
        ]
        pill_w = 110
        total_w = len(info_items) * pill_w + (len(info_items) - 1) * 10
        start_x = (self.width - total_w) / 2
        py = self.height * 0.38
        for label, value in info_items:
            c.setFillColor(HexColor('#0F3460'))
            c.roundRect(start_x, py - 5, pill_w, 40, 6, fill=1, stroke=0)
            c.setStrokeColor(COLOR_INFO)
            c.setLineWidth(0.8)
            c.roundRect(start_x, py - 5, pill_w, 40, 6, fill=0, stroke=1)
            c.setFillColor(COLOR_INFO)
            c.setFont('Helvetica-Bold', 7)
            c.drawCentredString(start_x + pill_w / 2, py + 22, label.upper())
            c.setFillColor(white)
            c.setFont('Helvetica', 9)
            c.drawCentredString(start_x + pill_w / 2, py + 8, value)
            start_x += pill_w + 10
        # Footer bar
        c.setFillColor(HexColor('#0A0A1A'))
        c.rect(0, 0, self.width, 60, fill=1, stroke=0)
        c.setFillColor(HexColor('#8B949E'))
        c.setFont('Helvetica', 9)
        c.drawCentredString(self.width / 2, 38,
                            f'Generated: {datetime.datetime.now().strftime("%B %d, %Y")}')
        c.drawCentredString(self.width / 2, 22,
                            'Copyright © 2024 VirtualOS Project  |  MIT License')


# ============================================================
# STYLE BUILDER
# ============================================================

def build_styles():
    base = getSampleStyleSheet()
    styles = {}

    def s(name, **kw):
        styles[name] = ParagraphStyle(name, **kw)

    s('Body',
      fontName='Helvetica', fontSize=10, leading=16,
      textColor=COLOR_TEXT_DARK, spaceAfter=8,
      spaceBefore=2, alignment=TA_LEFT)

    s('BodyJustify',
      fontName='Helvetica', fontSize=10, leading=16,
      textColor=COLOR_TEXT_DARK, spaceAfter=8, alignment=TA_JUSTIFY)

    s('H1',
      fontName='Helvetica-Bold', fontSize=22, leading=28,
      textColor=COLOR_PRIMARY, spaceAfter=12, spaceBefore=20)

    s('H2',
      fontName='Helvetica-Bold', fontSize=16, leading=22,
      textColor=COLOR_ACCENT, spaceAfter=8, spaceBefore=16)

    s('H3',
      fontName='Helvetica-Bold', fontSize=13, leading=18,
      textColor=COLOR_PRIMARY, spaceAfter=6, spaceBefore=12)

    s('H4',
      fontName='Helvetica-Bold', fontSize=11, leading=16,
      textColor=COLOR_ACCENT, spaceAfter=4, spaceBefore=8)

    s('Code',
      fontName='Courier', fontSize=8.5, leading=13,
      textColor=COLOR_TERMINAL_TEXT, backColor=COLOR_CODE_BG,
      borderPadding=(4, 6, 4, 6), spaceAfter=8)

    s('InlineCode',
      fontName='Courier-Bold', fontSize=9, leading=14,
      textColor=COLOR_HIGHLIGHT)

    s('TableHeader',
      fontName='Helvetica-Bold', fontSize=9, leading=13,
      textColor=white, alignment=TA_CENTER)

    s('TableCell',
      fontName='Helvetica', fontSize=9, leading=13,
      textColor=COLOR_TEXT_DARK, alignment=TA_LEFT)

    s('TableCellCenter',
      fontName='Helvetica', fontSize=9, leading=13,
      textColor=COLOR_TEXT_DARK, alignment=TA_CENTER)

    s('TableCellCode',
      fontName='Courier-Bold', fontSize=8.5, leading=13,
      textColor=COLOR_PRIMARY, alignment=TA_LEFT)

    s('Caption',
      fontName='Helvetica', fontSize=8, leading=12,
      textColor=COLOR_TEXT_MED, alignment=TA_CENTER, spaceAfter=4)

    s('Bullet',
      fontName='Helvetica', fontSize=10, leading=15,
      textColor=COLOR_TEXT_DARK, leftIndent=20, spaceAfter=3,
      bulletIndent=8, bulletFontName='Helvetica-Bold',
      bulletFontSize=10, bulletColor=COLOR_HIGHLIGHT)

    s('SubBullet',
      fontName='Helvetica', fontSize=9.5, leading=14,
      textColor=COLOR_TEXT_DARK, leftIndent=36, spaceAfter=2,
      bulletIndent=22, bulletFontName='Helvetica',
      bulletFontSize=9)

    s('Note',
      fontName='Helvetica-Oblique', fontSize=9, leading=14,
      textColor=COLOR_TEXT_MED, leftIndent=10, spaceAfter=6)

    s('TOCTitle',
      fontName='Helvetica-Bold', fontSize=18, leading=24,
      textColor=COLOR_PRIMARY, spaceAfter=16, alignment=TA_CENTER)

    s('TOCSection',
      fontName='Helvetica-Bold', fontSize=11, leading=16,
      textColor=COLOR_PRIMARY, leftIndent=0, spaceAfter=4)

    s('TOCItem',
      fontName='Helvetica', fontSize=10, leading=15,
      textColor=COLOR_TEXT_MED, leftIndent=18, spaceAfter=2)

    s('TOCSubItem',
      fontName='Helvetica', fontSize=9, leading=14,
      textColor=COLOR_TEXT_MED, leftIndent=32, spaceAfter=1)

    s('PageTitle',
      fontName='Helvetica-Bold', fontSize=24, leading=30,
      textColor=COLOR_PRIMARY, spaceAfter=4, alignment=TA_CENTER)

    s('PageSubtitle',
      fontName='Helvetica', fontSize=12, leading=18,
      textColor=COLOR_TEXT_MED, spaceAfter=20, alignment=TA_CENTER)

    s('CredentialUser',
      fontName='Courier-Bold', fontSize=11, leading=16,
      textColor=COLOR_PRIMARY)

    s('CredentialPass',
      fontName='Courier', fontSize=11, leading=16,
      textColor=COLOR_HIGHLIGHT)

    return styles


# ============================================================
# TABLE BUILDER HELPERS
# ============================================================

def make_table(data, col_widths, style_extra=None, header=True):
    """Build a styled table."""
    ts = TableStyle([
        # Header
        ('BACKGROUND',  (0, 0), (-1, 0), COLOR_TABLE_HEADER),
        ('TEXTCOLOR',   (0, 0), (-1, 0), white),
        ('FONTNAME',    (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE',    (0, 0), (-1, 0), 9),
        ('ALIGN',       (0, 0), (-1, 0), 'CENTER'),
        ('VALIGN',      (0, 0), (-1, -1), 'MIDDLE'),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1),
         [COLOR_TABLE_ROW1, COLOR_TABLE_ROW2]),
        ('FONTNAME',    (0, 1), (-1, -1), 'Helvetica'),
        ('FONTSIZE',    (0, 1), (-1, -1), 9),
        ('GRID',        (0, 0), (-1, -1), 0.4, COLOR_BORDER),
        ('TOPPADDING',  (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
        ('ROWBACKGROUNDS', (0, 0), (-1, 0), [COLOR_TABLE_HEADER]),
        ('LINEBELOW',   (0, 0), (-1, 0), 2, COLOR_HIGHLIGHT),
        ('ROUNDEDCORNERS', [4]),
    ])
    if style_extra:
        for rule in style_extra:
            ts.add(*rule)
    t = Table(data, colWidths=col_widths)
    t.setStyle(ts)
    return t


def cmd_table(commands, styles, widths=None):
    """Command reference table."""
    W = PAGE_WIDTH - 2 * inch
    w = widths or [W * 0.22, W * 0.33, W * 0.45]
    header = [
        Paragraph('Command', styles['TableHeader']),
        Paragraph('Syntax', styles['TableHeader']),
        Paragraph('Description', styles['TableHeader']),
    ]
    rows = [header]
    for cmd, syn, desc in commands:
        rows.append([
            Paragraph(f'<font name="Courier-Bold" color="#1A1A2E">{cmd}</font>',
                      styles['TableCell']),
            Paragraph(f'<font name="Courier" color="#0F3460">{syn}</font>',
                      styles['TableCell']),
            Paragraph(desc, styles['TableCell']),
        ])
    extras = [
        ('TEXTCOLOR', (0, 1), (0, -1), COLOR_PRIMARY),
        ('FONTNAME',  (0, 1), (0, -1), 'Courier-Bold'),
    ]
    return make_table(rows, w, extras)


# ============================================================
# PAGE TEMPLATE (header / footer)
# ============================================================

class PageNumCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        canvas.Canvas.__init__(self, *args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            canvas.Canvas.showPage(self)
        canvas.Canvas.save(self)

    def draw_page_decorations(self, page_count):
        page = self._pageNumber
        w, h = PAGE_WIDTH, PAGE_HEIGHT

        if page == 1:
            return  # Cover page – no decoration

        # ---- Header ----
        self.setFillColor(COLOR_PRIMARY)
        self.rect(0, h - 36, w, 36, fill=1, stroke=0)
        self.setFillColor(COLOR_HIGHLIGHT)
        self.rect(0, h - 38, w, 2, fill=1, stroke=0)

        self.setFillColor(white)
        self.setFont('Helvetica-Bold', 9)
        self.drawString(inch * 0.6, h - 22, 'VirtualOS v1.0.0')
        self.setFont('Helvetica', 8)
        self.drawRightString(w - inch * 0.6, h - 22,
                             'Complete Documentation')

        # ---- Footer ----
        self.setFillColor(COLOR_PRIMARY)
        self.rect(0, 0, w, 28, fill=1, stroke=0)
        self.setFillColor(COLOR_HIGHLIGHT)
        self.rect(0, 28, w, 1.5, fill=1, stroke=0)

        self.setFillColor(HexColor('#8B949E'))
        self.setFont('Helvetica', 7.5)
        self.drawString(inch * 0.6, 10,
                        f'© 2024 VirtualOS Project  |  MIT License')
        self.setFillColor(white)
        self.setFont('Helvetica-Bold', 8)
        self.drawRightString(w - inch * 0.6, 10,
                             f'Page {page} of {page_count}')


# ============================================================
# DOCUMENT BUILDER
# ============================================================

class VirtualOSDoc:
    def __init__(self, filename='VirtualOS_Documentation.pdf'):
        self.filename = filename
        self.styles = build_styles()
        self.story = []
        self.W = PAGE_WIDTH - 2 * inch  # usable width

    # ---------- helpers ----------

    def p(self, text, style='Body'):
        self.story.append(Paragraph(text, self.styles[style]))

    def sp(self, h=0.15):
        self.story.append(Spacer(1, h * inch))

    def pb(self):
        self.story.append(PageBreak())

    def hr(self, color=None, thick=1):
        self.story.append(ColoredHRule(self.W, color or COLOR_BORDER, thick))
        self.sp(0.1)

    def section(self, number, title):
        self.story.append(Spacer(1, 0.2 * inch))
        self.story.append(SectionHeader(number, title, self.W))
        self.story.append(Spacer(1, 0.18 * inch))

    def subsection(self, title, icon=''):
        text = f'{icon}  {title}' if icon else title
        self.p(text, 'H2')
        self.hr(COLOR_ACCENT, 0.8)
        self.sp(0.05)

    def h3(self, title):
        self.p(title, 'H3')

    def h4(self, title):
        self.p(title, 'H4')

    def bullet(self, text, sub=False):
        style = 'SubBullet' if sub else 'Bullet'
        self.story.append(Paragraph(f'• {text}', self.styles[style]))

    def note(self, text, kind='Note'):
        icons = {'Note': '📝', 'Tip': '💡', 'Warning': '⚠️', 'Important': '🔴'}
        colors = {
            'Note': (HexColor('#EEF2FF'), COLOR_INFO),
            'Tip': (HexColor('#ECFDF5'), COLOR_SUCCESS),
            'Warning': (HexColor('#FFFBEB'), COLOR_WARNING),
            'Important': (HexColor('#FFF1F2'), COLOR_HIGHLIGHT),
        }
        bg, bc = colors.get(kind, colors['Note'])
        icon = icons.get(kind, '📝')
        self.story.append(
            InfoBox(f'{icon} {kind.upper()}', text, self.W, bg, bc))
        self.sp(0.1)

    def terminal(self, lines, title='Terminal'):
        if isinstance(lines, str):
            lines = [l for l in lines.split('\n')]
        self.story.append(TerminalBlock(lines, self.W, title))
        self.sp(0.12)

    def table(self, data, widths=None, extras=None):
        self.story.append(make_table(data, widths or [self.W], extras))
        self.sp(0.12)

    def cmd_ref(self, commands, widths=None):
        self.story.append(cmd_table(commands, self.styles, widths))
        self.sp(0.12)

    def badge(self, command, description):
        self.story.append(CommandBadge(command, description, self.W))
        self.sp(0.06)

    def feature_grid(self, features):
        """Two-column feature list."""
        rows = []
        for i in range(0, len(features), 2):
            row = [features[i]]
            row.append(features[i + 1] if i + 1 < len(features) else '')
            rows.append(row)

        cell_style = ParagraphStyle(
            'FC', fontName='Helvetica', fontSize=9.5,
            leading=14, textColor=COLOR_TEXT_DARK,
            leftIndent=4)

        data = [[
            Paragraph(f'<font color="#E94560">✓</font>  {a}', cell_style),
            Paragraph(f'<font color="#E94560">✓</font>  {b}', cell_style)
            if b else Paragraph('', cell_style)
        ] for a, b in rows]

        ts = TableStyle([
            ('VALIGN',  (0, 0), (-1, -1), 'TOP'),
            ('TOPPADDING', (0, 0), (-1, -1), 5),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
            ('LEFTPADDING', (0, 0), (-1, -1), 8),
            ('ROWBACKGROUNDS', (0, 0), (-1, -1),
             [COLOR_TABLE_ROW1, COLOR_TABLE_ROW2]),
            ('GRID', (0, 0), (-1, -1), 0.3, COLOR_BORDER),
        ])
        t = Table(data, colWidths=[self.W / 2, self.W / 2])
        t.setStyle(ts)
        self.story.append(t)
        self.sp(0.12)

    # ---------- page sections ----------

    def build_cover(self):
        self.story.append(CoverPage(PAGE_WIDTH, PAGE_HEIGHT))
        self.pb()

    def build_toc(self):
        self.p('Table of Contents', 'TOCTitle')
        self.hr(COLOR_HIGHLIGHT, 2)
        self.sp(0.15)

        sections = [
            ('1', 'Overview & Introduction', [
                ('1.1', 'What is VirtualOS?'),
                ('1.2', 'Key Features'),
                ('1.3', 'System Architecture'),
                ('1.4', 'Technology Stack'),
            ]),
            ('2', 'Installation & Setup', [
                ('2.1', 'Requirements'),
                ('2.2', 'Installation Methods'),
                ('2.3', 'First Launch'),
                ('2.4', 'Launch Options'),
            ]),
            ('3', 'User Authentication', [
                ('3.1', 'Login Credentials'),
                ('3.2', 'User Accounts'),
                ('3.3', 'Privilege Management'),
                ('3.4', 'Security Features'),
            ]),
            ('4', 'Virtual Filesystem', [
                ('4.1', 'Directory Structure'),
                ('4.2', 'System Files'),
                ('4.3', 'User Files'),
                ('4.4', 'Virtual Devices'),
            ]),
            ('5', 'Command Reference', [
                ('5.1', 'File System Commands'),
                ('5.2', 'Process Management'),
                ('5.3', 'User Management'),
                ('5.4', 'System Information'),
                ('5.5', 'Network Commands'),
                ('5.6', 'Text Processing'),
                ('5.7', 'Archive & Compression'),
                ('5.8', 'Miscellaneous Utilities'),
            ]),
            ('6', 'Package Manager', [
                ('6.1', 'APT Commands'),
                ('6.2', 'Available Packages'),
                ('6.3', 'Package Database'),
            ]),
            ('7', 'Service Manager', [
                ('7.1', 'Service Commands'),
                ('7.2', 'Available Services'),
                ('7.3', 'Systemctl Interface'),
            ]),
            ('8', 'Text Editor (VEdit)', [
                ('8.1', 'Opening Files'),
                ('8.2', 'Editor Commands'),
                ('8.3', 'Usage Examples'),
            ]),
            ('9', 'Network Simulation', [
                ('9.1', 'Interface Configuration'),
                ('9.2', 'Connectivity Tools'),
                ('9.3', 'Network Monitoring'),
            ]),
            ('10', 'Shell Features', [
                ('10.1', 'Redirection & Piping'),
                ('10.2', 'Command Chaining'),
                ('10.3', 'Aliases'),
                ('10.4', 'Environment Variables'),
                ('10.5', 'Command History'),
            ]),
            ('11', 'System Logs & Monitoring', [
                ('11.1', 'Log Files'),
                ('11.2', 'journalctl'),
                ('11.3', 'dmesg'),
                ('11.4', 'System Monitoring'),
            ]),
            ('12', 'Configuration & Customization', [
                ('12.1', 'Changing Credentials'),
                ('12.2', 'Adding Packages'),
                ('12.3', 'Custom Services'),
                ('12.4', 'Aliases & Environment'),
            ]),
            ('13', 'Troubleshooting', [
                ('13.1', 'Common Issues'),
                ('13.2', 'Reset & Recovery'),
                ('13.3', 'Performance Tips'),
            ]),
            ('14', 'Changelog & License', [
                ('14.1', 'Version History'),
                ('14.2', 'MIT License'),
            ]),
        ]

        toc_bg = HexColor('#F8F9FF')
        toc_data = []
        for num, title, subs in sections:
            toc_data.append([
                Paragraph(
                    f'<font name="Helvetica-Bold" color="#1A1A2E">'
                    f'{num}.</font>  '
                    f'<font name="Helvetica-Bold" color="#1A1A2E">{title}</font>',
                    self.styles['TOCSection'])
            ])
            for sub_num, sub_title in subs:
                toc_data.append([
                    Paragraph(
                        f'<font name="Helvetica" color="#8B949E">    '
                        f'{sub_num}</font>  '
                        f'<font name="Helvetica" color="#656D76">{sub_title}</font>',
                        self.styles['TOCItem'])
                ])

        ts = TableStyle([
            ('VALIGN',  (0, 0), (-1, -1), 'MIDDLE'),
            ('LEFTPADDING', (0, 0), (-1, -1), 12),
            ('RIGHTPADDING', (0, 0), (-1, -1), 12),
            ('TOPPADDING', (0, 0), (-1, -1), 3),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 3),
            ('ROWBACKGROUNDS', (0, 0), (-1, -1),
             [COLOR_TABLE_ROW1, COLOR_TABLE_ROW2]),
        ])
        t = Table(toc_data, colWidths=[self.W])
        t.setStyle(ts)
        self.story.append(t)
        self.pb()

    # ============================================================
    # SECTION 1 – OVERVIEW
    # ============================================================
    def build_section1(self):
        self.section(1, 'Overview & Introduction')

        self.subsection('What is VirtualOS?', '🖥️')
        self.p(
            '<b>VirtualOS</b> is a fully self-contained virtual operating system '
            'implemented as a single Bash shell script (<font name="Courier-Bold">'
            'virtualos.sh</font>) designed to run inside '
            '<b>Termux</b> on Android devices. It emulates a complete '
            'Linux-like environment including a hierarchical filesystem, '
            'multi-user authentication, process management, package management, '
            'network simulation, service control, a text editor, logging, '
            'and over <b>100 built-in commands</b> — all without requiring '
            'root access or any external dependencies beyond Bash.',
            'BodyJustify')

        self.sp(0.1)
        self.note(
            'VirtualOS stores its entire virtual filesystem under ~/.virtualos/ '
            'on the real Android filesystem. No system files are modified.',
            'Important')

        self.sp(0.1)
        self.h3('Design Philosophy')
        design_items = [
            ('Single File', 'Entire OS in one .sh file — trivial to share, backup, and deploy'),
            ('Zero Dependencies', 'Works with just Bash — no additional packages required'),
            ('Safe Sandbox', 'All operations sandboxed inside ~/.virtualos — no system risk'),
            ('Educational', 'Ideal for learning Linux commands, scripting, and system administration'),
            ('Realistic', 'Faithfully simulates Linux behavior with color output and animations'),
            ('Extensible', 'Easy to add new commands, packages, and services'),
        ]
        header_row = [
            Paragraph('Principle', self.styles['TableHeader']),
            Paragraph('Description', self.styles['TableHeader']),
        ]
        rows = [header_row] + [
            [Paragraph(f'<font name="Helvetica-Bold" color="#E94560">{p}</font>',
                       self.styles['TableCell']),
             Paragraph(d, self.styles['TableCell'])]
            for p, d in design_items
        ]
        self.table(rows, [self.W * 0.25, self.W * 0.75])

        # ---- Key Features ----
        self.subsection('Key Features', '✨')
        features = [
            'Complete Linux filesystem hierarchy',
            'Over 100 built-in commands',
            'Animated boot sequence & BIOS POST',
            'Multi-user login system',
            'Root / standard user privileges',
            'APT-like package manager (20+ pkgs)',
            'Real-time process viewer (top)',
            'Service manager (start/stop/restart)',
            'Built-in text editor (VEdit)',
            'Network simulation (ping, ifconfig)',
            'Output redirection (>, >>)',
            'Pipeline operator (|)',
            'Command chaining (;, &&, ||)',
            'Command history & aliases',
            'Environment variable management',
            'System log viewer (journalctl)',
            'Kernel message log (dmesg)',
            'Disk and memory simulation',
            'neofetch system info display',
            'Shutdown/reboot simulation',
            'Crontab management',
            'Archive tools (tar, zip)',
            'Checksum utilities (md5, sha256)',
            'Base64 encode/decode',
        ]
        self.feature_grid(features)

        # ---- Architecture ----
        self.subsection('System Architecture', '🏗️')
        self.p(
            'VirtualOS is structured as seven major subsystems that interact '
            'through a central command dispatcher. The architecture follows a '
            'layered approach mimicking a real operating system kernel and '
            'userspace separation.',
            'BodyJustify')

        arch_data = [
            [Paragraph('Layer', self.styles['TableHeader']),
             Paragraph('Component', self.styles['TableHeader']),
             Paragraph('Responsibility', self.styles['TableHeader'])],
            [Paragraph('Boot Layer', self.styles['TableCell']),
             Paragraph('Boot Sequence + Login Screen', self.styles['TableCellCode']),
             Paragraph('BIOS POST simulation, kernel loading animation, '
                       'user authentication', self.styles['TableCell'])],
            [Paragraph('Shell Layer', self.styles['TableCell']),
             Paragraph('Main Loop + Command Processor', self.styles['TableCellCode']),
             Paragraph('Prompt generation, input reading, alias expansion, '
                       'redirection, piping, chaining', self.styles['TableCell'])],
            [Paragraph('Command Layer', self.styles['TableCell']),
             Paragraph('execute_command() Dispatcher', self.styles['TableCellCode']),
             Paragraph('Routes parsed commands to appropriate handler functions',
                       self.styles['TableCell'])],
            [Paragraph('FS Layer', self.styles['TableCell']),
             Paragraph('Virtual Filesystem (VFS)', self.styles['TableCellCode']),
             Paragraph('Path resolution, real directory mapping, '
                       'permission simulation', self.styles['TableCell'])],
            [Paragraph('Process Layer', self.styles['TableCell']),
             Paragraph('Process Table (Bash Arrays)', self.styles['TableCellCode']),
             Paragraph('PID management, process status tracking, '
                       'signal simulation', self.styles['TableCell'])],
            [Paragraph('User Layer', self.styles['TableCell']),
             Paragraph('User DB + Auth System', self.styles['TableCellCode']),
             Paragraph('Multi-user accounts, password verification, '
                       'privilege escalation', self.styles['TableCell'])],
            [Paragraph('Service Layer', self.styles['TableCell']),
             Paragraph('Service Manager', self.styles['TableCellCode']),
             Paragraph('Service state management, systemctl emulation',
                       self.styles['TableCell'])],
        ]
        self.table(arch_data, [self.W * 0.17, self.W * 0.30, self.W * 0.53])

        # ---- Technology Stack ----
        self.subsection('Technology Stack', '⚡')
        tech_data = [
            [Paragraph('Technology', self.styles['TableHeader']),
             Paragraph('Version', self.styles['TableHeader']),
             Paragraph('Usage', self.styles['TableHeader'])],
            [Paragraph('Bash', self.styles['TableCellCode']),
             Paragraph('4.0+', self.styles['TableCellCenter']),
             Paragraph('Primary scripting language', self.styles['TableCell'])],
            [Paragraph('ANSI Escape Codes', self.styles['TableCellCode']),
             Paragraph('Standard', self.styles['TableCellCenter']),
             Paragraph('Terminal colors and formatting', self.styles['TableCell'])],
            [Paragraph('Bash Associative Arrays', self.styles['TableCellCode']),
             Paragraph('Bash 4+', self.styles['TableCellCenter']),
             Paragraph('Process table, aliases, services, env vars',
                       self.styles['TableCell'])],
            [Paragraph('Termux', self.styles['TableCellCode']),
             Paragraph('Any', self.styles['TableCellCenter']),
             Paragraph('Android terminal host environment', self.styles['TableCell'])],
            [Paragraph('POSIX Filesystem', self.styles['TableCellCode']),
             Paragraph('Standard', self.styles['TableCellCenter']),
             Paragraph('Real directory backing for virtual FS',
                       self.styles['TableCell'])],
        ]
        self.table(tech_data, [self.W * 0.30, self.W * 0.15, self.W * 0.55])
        self.pb()

    # ============================================================
    # SECTION 2 – INSTALLATION
    # ============================================================
    def build_section2(self):
        self.section(2, 'Installation & Setup')

        self.subsection('Requirements', '📦')
        req_data = [
            [Paragraph('Requirement', self.styles['TableHeader']),
             Paragraph('Minimum', self.styles['TableHeader']),
             Paragraph('Recommended', self.styles['TableHeader']),
             Paragraph('Notes', self.styles['TableHeader'])],
            [Paragraph('Platform', self.styles['TableCell']),
             Paragraph('Android 7+', self.styles['TableCellCenter']),
             Paragraph('Android 10+', self.styles['TableCellCenter']),
             Paragraph('Termux must be installed', self.styles['TableCell'])],
            [Paragraph('Bash', self.styles['TableCell']),
             Paragraph('4.0', self.styles['TableCellCenter']),
             Paragraph('5.x', self.styles['TableCellCenter']),
             Paragraph('Included with Termux', self.styles['TableCell'])],
            [Paragraph('Storage', self.styles['TableCell']),
             Paragraph('3 MB', self.styles['TableCellCenter']),
             Paragraph('10 MB', self.styles['TableCellCenter']),
             Paragraph('Script + virtual filesystem', self.styles['TableCell'])],
            [Paragraph('RAM', self.styles['TableCell']),
             Paragraph('50 MB', self.styles['TableCellCenter']),
             Paragraph('200 MB', self.styles['TableCellCenter']),
             Paragraph('Minimal footprint', self.styles['TableCell'])],
            [Paragraph('Root Access', self.styles['TableCell']),
             Paragraph('❌ Not Required', self.styles['TableCellCenter']),
             Paragraph('❌ Not Required', self.styles['TableCellCenter']),
             Paragraph('Fully rootless operation', self.styles['TableCell'])],
        ]
        self.table(req_data,
                   [self.W*0.18, self.W*0.18, self.W*0.20, self.W*0.44])

        self.subsection('Installation Methods', '🚀')

        self.h3('Method 1: Quick One-Line Install')
        self.terminal([
            '$ curl -sL https://raw.githubusercontent.com/user/virtualos/main/virtualos.sh \\',
            '       -o virtualos.sh && chmod +x virtualos.sh && ./virtualos.sh',
        ], 'Quick Install')

        self.h3('Method 2: Manual Installation')
        self.terminal([
            '# Step 1: Update Termux packages',
            '$ pkg update && pkg upgrade -y',
            '',
            '# Step 2: Create the script',
            '$ nano virtualos.sh',
            '  (paste the complete script content)',
            '',
            '# Step 3: Make executable',
            '$ chmod +x virtualos.sh',
            '',
            '# Step 4: Launch VirtualOS',
            '$ ./virtualos.sh',
        ], 'Manual Installation')

        self.h3('Method 3: Git Clone')
        self.terminal([
            '$ git clone https://github.com/yourusername/virtualos.git',
            '$ cd virtualos',
            '$ chmod +x virtualos.sh',
            '$ ./virtualos.sh',
        ], 'Git Clone')

        self.h3('Method 4: wget')
        self.terminal([
            '$ wget https://raw.githubusercontent.com/user/virtualos/main/virtualos.sh',
            '$ chmod +x virtualos.sh',
            '$ ./virtualos.sh',
        ], 'wget Install')

        self.subsection('Launch Options', '⚙️')
        launch_data = [
            [Paragraph('Option', self.styles['TableHeader']),
             Paragraph('Description', self.styles['TableHeader']),
             Paragraph('Use Case', self.styles['TableHeader'])],
            [Paragraph('./virtualos.sh', self.styles['TableCellCode']),
             Paragraph('Full boot animation + login', self.styles['TableCell']),
             Paragraph('Normal startup', self.styles['TableCell'])],
            [Paragraph('./virtualos.sh --no-boot', self.styles['TableCellCode']),
             Paragraph('Skip boot animation', self.styles['TableCell']),
             Paragraph('Faster startup', self.styles['TableCell'])],
            [Paragraph('./virtualos.sh --no-login', self.styles['TableCellCode']),
             Paragraph('Skip login screen', self.styles['TableCell']),
             Paragraph('Development/testing', self.styles['TableCell'])],
            [Paragraph('./virtualos.sh --no-boot --no-login',
                       self.styles['TableCellCode']),
             Paragraph('Skip both sequences', self.styles['TableCell']),
             Paragraph('Maximum speed', self.styles['TableCell'])],
            [Paragraph('./virtualos.sh --reset', self.styles['TableCellCode']),
             Paragraph('Factory reset (deletes ~/.virtualos)',
                       self.styles['TableCell']),
             Paragraph('Start fresh', self.styles['TableCell'])],
            [Paragraph('./virtualos.sh --version', self.styles['TableCellCode']),
             Paragraph('Display version info', self.styles['TableCell']),
             Paragraph('Version check', self.styles['TableCell'])],
            [Paragraph('./virtualos.sh --help', self.styles['TableCellCode']),
             Paragraph('Show launch help', self.styles['TableCell']),
             Paragraph('Reference', self.styles['TableCell'])],
        ]
        self.table(launch_data, [self.W*0.38, self.W*0.35, self.W*0.27])
        self.pb()

    # ============================================================
    # SECTION 3 – AUTHENTICATION
    # ============================================================
    def build_section3(self):
        self.section(3, 'User Authentication')

        self.subsection('Login Credentials', '🔐')
        self.p('VirtualOS ships with two pre-configured user accounts:')

        cred_data = [
            [Paragraph('Username', self.styles['TableHeader']),
             Paragraph('Password', self.styles['TableHeader']),
             Paragraph('Role', self.styles['TableHeader']),
             Paragraph('Home Directory', self.styles['TableHeader']),
             Paragraph('UID', self.styles['TableHeader'])],
            [Paragraph('user', self.styles['TableCellCode']),
             Paragraph('password  (or empty)', self.styles['CredentialPass']
                       if 'CredentialPass' in self.styles else self.styles['TableCell']),
             Paragraph('Standard User', self.styles['TableCell']),
             Paragraph('/home/user', self.styles['TableCellCode']),
             Paragraph('1000', self.styles['TableCellCenter'])],
            [Paragraph('root', self.styles['TableCellCode']),
             Paragraph('toor', self.styles['TableCell']),
             Paragraph('Superuser', self.styles['TableCell']),
             Paragraph('/root', self.styles['TableCellCode']),
             Paragraph('0', self.styles['TableCellCenter'])],
        ]
        extras = [
            ('TEXTCOLOR', (1, 1), (1, 1), COLOR_SUCCESS),
            ('FONTNAME', (1, 1), (1, 1), 'Courier-Bold'),
            ('TEXTCOLOR', (1, 2), (1, 2), COLOR_HIGHLIGHT),
            ('FONTNAME', (1, 2), (1, 2), 'Courier-Bold'),
        ]
        self.table(cred_data,
                   [self.W*0.15, self.W*0.22, self.W*0.20, self.W*0.25, self.W*0.18],
                   extras)

        self.note(
            'For security, change default passwords in production. '
            'Edit the init_system_files() function and cmd_su()/cmd_sudo() '
            'to update credentials.',
            'Warning')

        self.subsection('Privilege Management', '🔑')
        self.h3('Switching to Root')
        self.terminal([
            '$ whoami',
            'user',
            '',
            '$ su',
            '[sudo] password for root: ',
            '(enter: toor)',
            'Switched to root',
            '',
            '# whoami',
            'root',
            '',
            '# id',
            'uid=0(root) gid=0(root) groups=0(root)',
        ], 'Switch to Root')

        self.h3('Using sudo')
        self.terminal([
            '$ sudo apt install nginx',
            '[sudo] password for user: ',
            '(enter: password)',
            'Installing nginx...',
            'nginx (1.23.0) successfully installed',
        ], 'sudo Example')

        self.h3('User Management Commands')
        self.cmd_ref([
            ('su', 'su [username]', 'Switch to another user account'),
            ('sudo', 'sudo <command>', 'Execute command as superuser'),
            ('whoami', 'whoami', 'Display current logged-in username'),
            ('id', 'id', 'Display user and group IDs'),
            ('useradd', 'useradd <name>', 'Create a new user (root only)'),
            ('userdel', 'userdel <name>', 'Delete a user account (root only)'),
            ('passwd', 'passwd [user]', 'Change user password'),
            ('groups', 'groups', 'Display group memberships'),
            ('who', 'who', 'Show who is logged in'),
            ('w', 'w', 'Show detailed user activity'),
            ('last', 'last', 'Show login history'),
        ])
        self.pb()

    # ============================================================
    # SECTION 4 – FILESYSTEM
    # ============================================================
    def build_section4(self):
        self.section(4, 'Virtual Filesystem')

        self.subsection('Directory Structure', '📁')
        self.p(
            'The virtual filesystem mirrors a standard Linux FHS (Filesystem '
            'Hierarchy Standard) layout. All directories are backed by real '
            'directories under <font name="Courier-Bold">~/.virtualos/root/</font> '
            'on the host Android filesystem.',
            'BodyJustify')

        dir_data = [
            [Paragraph('Virtual Path', self.styles['TableHeader']),
             Paragraph('Real Path', self.styles['TableHeader']),
             Paragraph('Contents & Purpose', self.styles['TableHeader'])],
            [Paragraph('/', self.styles['TableCellCode']),
             Paragraph('~/.virtualos/root/', self.styles['TableCellCode']),
             Paragraph('Virtual root filesystem', self.styles['TableCell'])],
            [Paragraph('/home/user/', self.styles['TableCellCode']),
             Paragraph('~/.virtualos/root/home/user/', self.styles['TableCellCode']),
             Paragraph('Default user home: Desktop, Documents, Downloads, '
                       'Music, Pictures, Videos', self.styles['TableCell'])],
            [Paragraph('/etc/', self.styles['TableCellCode']),
             Paragraph('~/.virtualos/root/etc/', self.styles['TableCellCode']),
             Paragraph('System config: passwd, shadow, group, hostname, '
                       'hosts, fstab, os-release, motd', self.styles['TableCell'])],
            [Paragraph('/proc/', self.styles['TableCellCode']),
             Paragraph('~/.virtualos/root/proc/', self.styles['TableCellCode']),
             Paragraph('Process info: cpuinfo, meminfo, version, uptime',
                       self.styles['TableCell'])],
            [Paragraph('/sys/', self.styles['TableCellCode']),
             Paragraph('~/.virtualos/root/sys/', self.styles['TableCellCode']),
             Paragraph('System info: kernel/version, kernel/hostname',
                       self.styles['TableCell'])],
            [Paragraph('/var/log/', self.styles['TableCellCode']),
             Paragraph('~/.virtualos/root/var/log/', self.styles['TableCellCode']),
             Paragraph('Log files: syslog, kern.log, auth.log',
                       self.styles['TableCell'])],
            [Paragraph('/var/packages/', self.styles['TableCellCode']),
             Paragraph('~/.virtualos/root/var/packages/', self.styles['TableCellCode']),
             Paragraph('Package databases: installed.db, available.db',
                       self.styles['TableCell'])],
            [Paragraph('/dev/', self.styles['TableCellCode']),
             Paragraph('~/.virtualos/root/dev/', self.styles['TableCellCode']),
             Paragraph('Device files: null, zero, random, urandom, tty',
                       self.styles['TableCell'])],
            [Paragraph('/tmp/', self.styles['TableCellCode']),
             Paragraph('~/.virtualos/root/tmp/', self.styles['TableCellCode']),
             Paragraph('Temporary files (cleared on reboot)',
                       self.styles['TableCell'])],
            [Paragraph('/boot/', self.styles['TableCellCode']),
             Paragraph('~/.virtualos/root/boot/', self.styles['TableCellCode']),
             Paragraph('Boot files: grub.cfg', self.styles['TableCell'])],
            [Paragraph('/mnt/', self.styles['TableCellCode']),
             Paragraph('~/.virtualos/root/mnt/', self.styles['TableCellCode']),
             Paragraph('Mount points: usb/, cdrom/', self.styles['TableCell'])],
            [Paragraph('/usr/bin/', self.styles['TableCellCode']),
             Paragraph('~/.virtualos/root/usr/bin/', self.styles['TableCellCode']),
             Paragraph('User binaries directory', self.styles['TableCell'])],
            [Paragraph('/root/', self.styles['TableCellCode']),
             Paragraph('~/.virtualos/root/root/', self.styles['TableCellCode']),
             Paragraph('Root user home directory', self.styles['TableCell'])],
        ]
        self.table(dir_data, [self.W*0.20, self.W*0.30, self.W*0.50])

        self.subsection('Virtual Devices', '⚡')
        dev_data = [
            [Paragraph('Device', self.styles['TableHeader']),
             Paragraph('Type', self.styles['TableHeader']),
             Paragraph('Description', self.styles['TableHeader'])],
            [Paragraph('/dev/null', self.styles['TableCellCode']),
             Paragraph('Character', self.styles['TableCellCenter']),
             Paragraph('Data sink — discards all input', self.styles['TableCell'])],
            [Paragraph('/dev/zero', self.styles['TableCellCode']),
             Paragraph('Character', self.styles['TableCellCenter']),
             Paragraph('Generates null bytes', self.styles['TableCell'])],
            [Paragraph('/dev/random', self.styles['TableCellCode']),
             Paragraph('Character', self.styles['TableCellCenter']),
             Paragraph('Random data source', self.styles['TableCell'])],
            [Paragraph('/dev/urandom', self.styles['TableCellCode']),
             Paragraph('Character', self.styles['TableCellCenter']),
             Paragraph('Non-blocking random data source', self.styles['TableCell'])],
            [Paragraph('/dev/tty', self.styles['TableCellCode']),
             Paragraph('Character', self.styles['TableCellCenter']),
             Paragraph('Current terminal device', self.styles['TableCell'])],
            [Paragraph('/dev/vda1', self.styles['TableCellCode']),
             Paragraph('Block', self.styles['TableCellCenter']),
             Paragraph('Virtual disk partition 1 (root)', self.styles['TableCell'])],
            [Paragraph('/dev/vda2', self.styles['TableCellCode']),
             Paragraph('Block', self.styles['TableCellCenter']),
             Paragraph('Virtual disk partition 2 (home)', self.styles['TableCell'])],
        ]
        self.table(dev_data, [self.W*0.25, self.W*0.18, self.W*0.57])
        self.pb()

    # ============================================================
    # SECTION 5 – COMMAND REFERENCE
    # ============================================================
    def build_section5(self):
        self.section(5, 'Command Reference')

        # 5.1 Filesystem
        self.subsection('5.1  File System Commands', '📁')
        self.cmd_ref([
            ('ls', 'ls [-l] [-a] [-h] [-r] [dir]',
             'List directory contents with color-coded output'),
            ('cd', 'cd [dir | ~ | .. | -]',
             'Change directory; cd - returns to previous'),
            ('pwd', 'pwd', 'Print absolute virtual working directory'),
            ('mkdir', 'mkdir [-p] [-v] <dir>',
             'Create directory; -p creates parent directories'),
            ('rmdir', 'rmdir <dir>', 'Remove empty directories only'),
            ('touch', 'touch <file> [file2...]',
             'Create file or update modification timestamp'),
            ('rm', 'rm [-r] [-f] [-i] <file>',
             'Remove files; -r recursive; -f force; -i interactive'),
            ('cp', 'cp [-r] <src> <dst>',
             'Copy files or directories; -r for recursive copy'),
            ('mv', 'mv <src> <dst>', 'Move or rename files and directories'),
            ('cat', 'cat [-n] <file>', 'Display file; -n adds line numbers'),
            ('head', 'head [-n N] <file>', 'Display first N lines (default: 10)'),
            ('tail', 'tail [-n N] <file>', 'Display last N lines (default: 10)'),
            ('less/more', 'less <file>', 'Page through file contents'),
            ('find', 'find [dir] [-name pat] [-type f|d]',
             'Search filesystem for files/directories'),
            ('grep', 'grep [-i] [-n] [-r] [-c] [-v] <pattern> <file>',
             'Search file contents with regex support'),
            ('tree', 'tree [-a] [-L N] [dir]',
             'Display directory tree; -L limits depth'),
            ('ln', 'ln [-s] <src> <dst>', 'Create hard or symbolic (-s) links'),
            ('stat', 'stat <file>', 'Detailed file/directory status information'),
            ('file', 'file <file>', 'Identify file type by extension'),
            ('wc', 'wc [-l] [-w] [-c] <file>',
             'Count lines, words, and characters'),
            ('du', 'du [-h] [-s] [dir]',
             'Disk usage; -h human readable; -s summary only'),
            ('df', 'df [-h]', 'Display filesystem free space'),
            ('diff', 'diff <file1> <file2>', 'Compare two files line by line'),
            ('chmod', 'chmod <mode> <file>', 'Change file permission mode'),
            ('chown', 'chown <owner>[:<group>] <file>',
             'Change file owner and group'),
            ('mount', 'mount [device mountpoint]', 'Mount or list filesystems'),
            ('umount', 'umount <mountpoint>', 'Unmount a filesystem'),
        ], [self.W*0.14, self.W*0.33, self.W*0.53])

        self.sp(0.1)
        self.note(
            'Safety: rm cannot remove root system directories (/etc, /proc, '
            '/sys, /var, /home, /dev, /usr, /boot). This prevents accidental '
            'destruction of the virtual OS.', 'Warning')

        # 5.2 Process Management
        self.subsection('5.2  Process Management', '⚙️')
        self.cmd_ref([
            ('ps', 'ps [aux | ef]', 'List running processes with status'),
            ('top', 'top', 'Real-time process viewer (press q to quit)'),
            ('htop', 'htop', 'Alias for top with enhanced display'),
            ('kill', 'kill [-signal] <pid>',
             'Send signal to process; -9 force kill'),
            ('killall', 'killall <name>', 'Kill all processes matching name'),
            ('bg', 'bg <command>', 'Launch command as background process'),
            ('jobs', 'jobs', 'List all background jobs with PIDs'),
            ('nohup', 'nohup <command>',
             'Run command immune to hangup signal'),
        ])

        self.h4('System Process Table (Default)')
        proc_data = [
            [Paragraph('PID', self.styles['TableHeader']),
             Paragraph('Process', self.styles['TableHeader']),
             Paragraph('Command', self.styles['TableHeader']),
             Paragraph('Status', self.styles['TableHeader'])],
            [Paragraph('1', self.styles['TableCellCenter']),
             Paragraph('init', self.styles['TableCellCode']),
             Paragraph('/sbin/init', self.styles['TableCellCode']),
             Paragraph('running', self.styles['TableCell'])],
            [Paragraph('2', self.styles['TableCellCenter']),
             Paragraph('kthreadd', self.styles['TableCellCode']),
             Paragraph('[kthreadd]', self.styles['TableCellCode']),
             Paragraph('running', self.styles['TableCell'])],
            [Paragraph('3', self.styles['TableCellCenter']),
             Paragraph('systemd-journald', self.styles['TableCellCode']),
             Paragraph('/usr/lib/systemd/systemd-journald',
                       self.styles['TableCellCode']),
             Paragraph('running', self.styles['TableCell'])],
            [Paragraph('10', self.styles['TableCellCenter']),
             Paragraph('syslogd', self.styles['TableCellCode']),
             Paragraph('/usr/sbin/syslogd', self.styles['TableCellCode']),
             Paragraph('running', self.styles['TableCell'])],
            [Paragraph('15', self.styles['TableCellCenter']),
             Paragraph('cron', self.styles['TableCellCode']),
             Paragraph('/usr/sbin/cron', self.styles['TableCellCode']),
             Paragraph('running', self.styles['TableCell'])],
            [Paragraph('20', self.styles['TableCellCenter']),
             Paragraph('networkd', self.styles['TableCellCode']),
             Paragraph('/usr/sbin/networkd', self.styles['TableCellCode']),
             Paragraph('running', self.styles['TableCell'])],
            [Paragraph('25', self.styles['TableCellCenter']),
             Paragraph('sshd', self.styles['TableCellCode']),
             Paragraph('/usr/sbin/sshd', self.styles['TableCellCode']),
             Paragraph('running', self.styles['TableCell'])],
        ]
        self.table(proc_data, [self.W*0.10, self.W*0.20, self.W*0.42, self.W*0.28])

        # 5.3 System Info
        self.subsection('5.3  System Information', '🖥️')
        self.cmd_ref([
            ('uname', 'uname [-a] [-s] [-r] [-n] [-m]',
             'Display kernel/system information'),
            ('hostname', 'hostname [newname]', 'Show or set system hostname'),
            ('uptime', 'uptime', 'Show system uptime and load average'),
            ('date', 'date [+format]', 'Display or format date and time'),
            ('cal', 'cal [month] [year]', 'Display a calendar'),
            ('free', 'free [-h] [-m]', 'Display memory usage statistics'),
            ('lscpu', 'lscpu', 'Display CPU architecture information'),
            ('lsblk', 'lsblk', 'List block devices and partitions'),
            ('lsusb', 'lsusb', 'List USB devices'),
            ('lspci', 'lspci', 'List PCI bus devices'),
            ('dmesg', 'dmesg [-n N]', 'Display kernel ring buffer messages'),
            ('neofetch', 'neofetch', 'System info with ASCII art logo'),
        ])

        # 5.4 Text Processing
        self.subsection('5.4  Text Processing', '📝')
        self.cmd_ref([
            ('echo', 'echo [-n] [-e] <text>', 'Print text; -n no newline; -e escapes'),
            ('sort', 'sort [-r] [-n] [-u] <file>',
             'Sort lines; -r reverse; -n numeric; -u unique'),
            ('uniq', 'uniq [file]', 'Filter adjacent duplicate lines'),
            ('cut', 'cut -d<delim> -f<fields> <file>',
             'Extract fields from lines by delimiter'),
            ('tr', 'tr <set1> <set2>', 'Translate or delete characters'),
            ('tee', 'tee [-a] <file>', 'Duplicate stdin to file and stdout'),
            ('xargs', 'xargs <command>', 'Build command arguments from stdin'),
            ('sed', 'sed <expr> [file]',
             'Stream editor for filtering/transforming text'),
            ('awk', "awk '{program}' [file]", 'Pattern scanning and processing'),
            ('grep', 'grep [-inrvcl] <pattern> <file>',
             'Search for pattern in files'),
            ('wc', 'wc [-lwc] <file>', 'Count lines, words, characters in file'),
            ('bc', 'bc', 'Interactive arbitrary precision calculator'),
            ('expr', 'expr <expression>', 'Evaluate arithmetic/string expression'),
            ('seq', 'seq [start [step]] end', 'Generate numeric sequences'),
            ('base64', 'base64 [-d] [file]', 'Encode or decode base64 data'),
            ('md5sum', 'md5sum <file>', 'Compute and verify MD5 checksums'),
            ('sha256sum', 'sha256sum <file>', 'Compute and verify SHA-256 checksums'),
        ])

        # 5.5 Archive
        self.subsection('5.5  Archive & Compression', '📦')
        self.cmd_ref([
            ('tar', 'tar czf <archive> <files>',
             'Create gzip-compressed tar archive'),
            ('tar', 'tar xzf <archive>',
             'Extract gzip-compressed tar archive'),
            ('tar', 'tar tzf <archive>',
             'List contents of tar archive'),
            ('zip', 'zip <archive> <files>', 'Create zip archive (simulated)'),
            ('unzip', 'unzip <archive>', 'Extract zip archive (simulated)'),
        ])
        self.pb()

    # ============================================================
    # SECTION 6 – PACKAGE MANAGER
    # ============================================================
    def build_section6(self):
        self.section(6, 'Package Manager')

        self.subsection('APT Commands', '📦')
        self.p(
            'VirtualOS includes a fully simulated APT package manager that '
            'mirrors the behavior of Debian/Ubuntu\'s <font name="Courier-Bold">'
            'apt</font> command. Packages are tracked in a virtual database '
            'at <font name="Courier-Bold">/var/packages/</font>.',
            'BodyJustify')

        self.cmd_ref([
            ('apt install', 'apt install <pkg> [pkg2...]',
             'Download and install one or more packages'),
            ('apt remove', 'apt remove <pkg>',
             'Remove an installed package'),
            ('apt update', 'apt update',
             'Refresh package lists from virtual repositories'),
            ('apt upgrade', 'apt upgrade',
             'Upgrade all installed packages'),
            ('apt list', 'apt list [--installed]',
             'List available or installed packages'),
            ('apt search', 'apt search <keyword>',
             'Search available packages by keyword'),
            ('apt show', 'apt show <pkg>',
             'Display detailed package information'),
            ('apt autoremove', 'apt autoremove',
             'Remove automatically installed unused packages'),
            ('apt clean', 'apt clean',
             'Clear the local package cache'),
        ])

        self.terminal([
            '$ apt update',
            'Hit:1 http://virtualos.repo/main stable InRelease',
            'Hit:2 http://virtualos.repo/universe stable InRelease',
            'Reading package lists... Done',
            '',
            '$ apt search python',
            '  python3         3.11.0    Python programming language',
            '',
            '$ apt install python3',
            'Reading package lists... Done',
            'Building dependency tree... Done',
            'The following NEW packages will be installed:',
            '  python3 (3.11.0)',
            'Do you want to continue? [Y/n] Y',
            'Downloading python3 (3.11.0)...',
            'Setting up python3 (3.11.0)...',
            'python3 (3.11.0) successfully installed',
        ], 'Package Manager Demo')

        self.subsection('Available Packages', '📋')
        pkg_data = [
            [Paragraph('Package', self.styles['TableHeader']),
             Paragraph('Version', self.styles['TableHeader']),
             Paragraph('Description', self.styles['TableHeader']),
             Paragraph('Category', self.styles['TableHeader'])],
        ]
        packages = [
            ('python3', '3.11.0', 'Python programming language', 'Development'),
            ('nodejs', '18.0.0', 'JavaScript runtime environment', 'Development'),
            ('gcc', '11.3.0', 'GNU C/C++ Compiler collection', 'Development'),
            ('git', '2.39.0', 'Distributed version control system', 'Tools'),
            ('vim', '9.0', 'Vi Improved text editor', 'Editors'),
            ('nano', '7.0', 'Simple terminal text editor', 'Editors'),
            ('curl', '7.88.0', 'Command-line URL transfer tool', 'Network'),
            ('wget', '1.21.0', 'Non-interactive network downloader', 'Network'),
            ('openssh', '9.2', 'OpenSSH secure shell suite', 'Network'),
            ('nginx', '1.23.0', 'High-performance HTTP web server', 'Server'),
            ('redis', '7.0.0', 'In-memory key-value data store', 'Server'),
            ('sqlite3', '3.41.0', 'Lightweight SQL database engine', 'Database'),
            ('htop', '3.2.0', 'Interactive process monitor', 'System'),
            ('tmux', '3.3', 'Terminal multiplexer', 'System'),
            ('neofetch', '7.1.0', 'System information display tool', 'System'),
            ('ruby', '3.2.0', 'Ruby programming language', 'Development'),
            ('perl', '5.36.0', 'Practical extraction/report language', 'Development'),
            ('lua', '5.4.0', 'Lightweight scripting language', 'Development'),
            ('docker', '23.0.0', 'Container runtime platform', 'Tools'),
            ('zip', '3.0', 'Compression and archiving utility', 'Tools'),
        ]
        for name, ver, desc, cat in packages:
            pkg_data.append([
                Paragraph(name, self.styles['TableCellCode']),
                Paragraph(ver, self.styles['TableCellCenter']),
                Paragraph(desc, self.styles['TableCell']),
                Paragraph(cat, self.styles['TableCellCenter']),
            ])
        self.table(pkg_data,
                   [self.W*0.18, self.W*0.14, self.W*0.46, self.W*0.22])
        self.pb()

    # ============================================================
    # SECTION 7 – SERVICE MANAGER
    # ============================================================
    def build_section7(self):
        self.section(7, 'Service Manager')

        self.subsection('Service Commands', '🔧')
        self.cmd_ref([
            ('service', 'service',
             'List all services with their current status'),
            ('service start', 'service <name> start',
             'Start a stopped service and add to process table'),
            ('service stop', 'service <name> stop',
             'Stop a running service and remove from process table'),
            ('service restart', 'service <name> restart',
             'Stop and restart a service'),
            ('service status', 'service <name> status',
             'Display detailed status of a service'),
            ('systemctl', 'systemctl [action] [service]',
             'Systemd-compatible service control interface'),
            ('systemctl list-units', 'systemctl list-units',
             'List all service units with status'),
            ('systemctl enable', 'systemctl enable <service>',
             'Enable service to start automatically'),
            ('systemctl disable', 'systemctl disable <service>',
             'Disable automatic service startup'),
        ])

        self.subsection('Available Services', '📋')
        svc_data = [
            [Paragraph('Service', self.styles['TableHeader']),
             Paragraph('Default Status', self.styles['TableHeader']),
             Paragraph('Port', self.styles['TableHeader']),
             Paragraph('Description', self.styles['TableHeader'])],
        ]
        services = [
            ('sshd', '✅ Running', '22', 'OpenSSH daemon — remote shell access'),
            ('networking', '✅ Running', 'N/A', 'Virtual network interface manager'),
            ('cron', '✅ Running', 'N/A', 'Scheduled task execution daemon'),
            ('syslog', '✅ Running', 'N/A', 'System and kernel log collector'),
            ('firewall', '❌ Stopped', 'N/A', 'Virtual firewall rule manager'),
            ('nginx', '❌ Stopped', '80/443', 'High-performance HTTP web server'),
            ('mysql', '❌ Stopped', '3306', 'MySQL relational database server'),
            ('redis', '❌ Stopped', '6379', 'In-memory key-value data store'),
        ]
        for name, status, port, desc in services:
            color = COLOR_SUCCESS if '✅' in status else COLOR_HIGHLIGHT
            svc_data.append([
                Paragraph(name, self.styles['TableCellCode']),
                Paragraph(status, self.styles['TableCell']),
                Paragraph(port, self.styles['TableCellCenter']),
                Paragraph(desc, self.styles['TableCell']),
            ])

        extras = [
            ('TEXTCOLOR', (1, 1), (1, 4), COLOR_SUCCESS),
            ('TEXTCOLOR', (1, 5), (1, 8), COLOR_HIGHLIGHT),
        ]
        self.table(svc_data,
                   [self.W*0.18, self.W*0.18, self.W*0.12, self.W*0.52],
                   extras)

        self.terminal([
            '$ service',
            '  sshd                running',
            '  networking          running',
            '  cron                running',
            '  syslog              running',
            '  firewall            stopped',
            '  nginx               stopped',
            '',
            '$ service nginx start',
            'Starting nginx... OK',
            '',
            '$ service nginx status',
            '● nginx - Virtual Service',
            '   Status: running',
            '   PID: 312',
            '   Since: 2024-01-15 10:30:00',
        ], 'Service Manager Demo')
        self.pb()

    # ============================================================
    # SECTION 8 – TEXT EDITOR
    # ============================================================
    def build_section8(self):
        self.section(8, 'Text Editor — VEdit')

        self.subsection('Overview', '📝')
        self.p(
            'VEdit is VirtualOS\'s built-in interactive text editor. It provides '
            'a line-by-line editing interface with file save/load capabilities, '
            'content display, and line deletion. VEdit is accessible via '
            '<font name="Courier-Bold">vedit</font>, '
            '<font name="Courier-Bold">nano</font>, '
            '<font name="Courier-Bold">vi</font>, or '
            '<font name="Courier-Bold">vim</font> commands.',
            'BodyJustify')

        self.subsection('Editor Commands', '⌨️')
        ed_data = [
            [Paragraph('Command', self.styles['TableHeader']),
             Paragraph('Action', self.styles['TableHeader']),
             Paragraph('Notes', self.styles['TableHeader'])],
        ]
        editor_cmds = [
            (':w', 'Save file', 'Prompts for filename if not specified'),
            (':q', 'Quit editor', 'Warns if there are unsaved changes'),
            (':q!', 'Force quit', 'Exits without saving — no warning'),
            (':wq', 'Save and quit', 'Saves then immediately exits editor'),
            (':show', 'Display content', 'Shows all lines with line numbers'),
            (':clear', 'Clear content', 'Removes all lines from buffer'),
            (':del N', 'Delete line N', 'Removes the specified line number'),
            (':help', 'Show help', 'Displays all available editor commands'),
        ]
        for cmd, action, notes in editor_cmds:
            ed_data.append([
                Paragraph(cmd, self.styles['TableCellCode']),
                Paragraph(action, self.styles['TableCell']),
                Paragraph(notes, self.styles['TableCell']),
            ])
        self.table(ed_data, [self.W*0.18, self.W*0.30, self.W*0.52])

        self.terminal([
            '$ vedit myfile.txt',
            '',
            '╔══════════════════════════════════════════════════╗',
            '║  VEdit - Virtual Text Editor v1.0              ║',
            '║  File: myfile.txt                              ║',
            '╠══════════════════════════════════════════════════╣',
            '║ Commands: :w (save) :q (quit) :wq (save+quit)  ║',
            '╚══════════════════════════════════════════════════╝',
            '',
            'Enter text (type :w to save, :q to quit):',
            '',
            '1│ Hello, VirtualOS!',
            '2│ This is my first file.',
            '3│ :show',
            '--- Content ---',
            '  1│ Hello, VirtualOS!',
            '  2│ This is my first file.',
            '--- End (2 lines) ---',
            '3│ :wq',
            'File saved: myfile.txt',
        ], 'VEdit Session')
        self.pb()

    # ============================================================
    # SECTION 9 – NETWORK
    # ============================================================
    def build_section9(self):
        self.section(9, 'Network Simulation')

        self.subsection('Network Commands', '🌐')
        self.cmd_ref([
            ('ifconfig', 'ifconfig',
             'Display network interface configuration (eth0, lo)'),
            ('ip addr', 'ip addr | ip a',
             'Show IP addresses for all interfaces'),
            ('ip route', 'ip route | ip r',
             'Show routing table'),
            ('ip link', 'ip link | ip l',
             'Show link layer information'),
            ('ip neigh', 'ip neigh | ip n',
             'Show ARP neighbor table'),
            ('ping', 'ping [-c N] <host>',
             'Send ICMP echo requests with real 1-second delays'),
            ('netstat', 'netstat',
             'Show network connections, listen ports, routing'),
            ('ss', 'ss',
             'Socket statistics — modern netstat replacement'),
            ('curl', 'curl <url>',
             'Transfer data from URL (simulated HTTP response)'),
            ('wget', 'wget <url>',
             'Download files from URLs (creates local file)'),
            ('nslookup', 'nslookup <hostname>',
             'Query DNS for hostname-to-IP resolution'),
            ('dig', 'dig <hostname>',
             'DNS lookup utility (alias for nslookup)'),
            ('traceroute', 'traceroute <host>',
             'Trace network path to destination host'),
        ])

        self.terminal([
            '$ ifconfig',
            'eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500',
            '        inet 192.168.1.142  netmask 255.255.255.0  broadcast 192.168.1.255',
            '        ether 00:16:3e:a4:b2:c1  txqueuelen 1000',
            '        RX packets 5423  bytes 782341',
            '        TX packets 2187  bytes 198432',
            '',
            'lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536',
            '        inet 127.0.0.1  netmask 255.0.0.0',
            '',
            '$ ping -c 3 google.com',
            'PING google.com (142.250.80.46): 56 data bytes',
            '64 bytes from 142.250.80.46: icmp_seq=1 ttl=64 time=23.412 ms',
            '64 bytes from 142.250.80.46: icmp_seq=2 ttl=64 time=19.876 ms',
            '64 bytes from 142.250.80.46: icmp_seq=3 ttl=64 time=21.543 ms',
            '--- google.com ping statistics ---',
            '3 packets transmitted, 3 packets received, 0% packet loss',
        ], 'Network Commands Demo')
        self.pb()

    # ============================================================
    # SECTION 10 – SHELL FEATURES
    # ============================================================
    def build_section10(self):
        self.section(10, 'Shell Features')

        self.subsection('Output Redirection', '➡️')
        self.p('VirtualOS shell supports standard output redirection operators:')
        redir_data = [
            [Paragraph('Operator', self.styles['TableHeader']),
             Paragraph('Function', self.styles['TableHeader']),
             Paragraph('Example', self.styles['TableHeader'])],
            [Paragraph('>', self.styles['TableCellCode']),
             Paragraph('Redirect stdout to file (overwrite)',
                       self.styles['TableCell']),
             Paragraph('ls -la > filelist.txt', self.styles['TableCellCode'])],
            [Paragraph('>>', self.styles['TableCellCode']),
             Paragraph('Redirect stdout to file (append)',
                       self.styles['TableCell']),
             Paragraph('date >> log.txt', self.styles['TableCellCode'])],
            [Paragraph('|', self.styles['TableCellCode']),
             Paragraph('Pipe stdout of left to stdin of right',
                       self.styles['TableCell']),
             Paragraph('ps aux | grep sshd', self.styles['TableCellCode'])],
        ]
        self.table(redir_data, [self.W*0.12, self.W*0.40, self.W*0.48])

        self.subsection('Command Chaining', '🔗')
        chain_data = [
            [Paragraph('Operator', self.styles['TableHeader']),
             Paragraph('Behavior', self.styles['TableHeader']),
             Paragraph('Example', self.styles['TableHeader'])],
            [Paragraph(';', self.styles['TableCellCode']),
             Paragraph('Run commands sequentially regardless of exit code',
                       self.styles['TableCell']),
             Paragraph('mkdir test; cd test; touch file',
                       self.styles['TableCellCode'])],
            [Paragraph('&&', self.styles['TableCellCode']),
             Paragraph('Run next command only if previous succeeded (exit 0)',
                       self.styles['TableCell']),
             Paragraph('apt update && apt upgrade',
                       self.styles['TableCellCode'])],
            [Paragraph('||', self.styles['TableCellCode']),
             Paragraph('Run next command only if previous failed (exit != 0)',
                       self.styles['TableCell']),
             Paragraph('cd docs || mkdir docs', self.styles['TableCellCode'])],
        ]
        self.table(chain_data, [self.W*0.10, self.W*0.47, self.W*0.43])

        self.subsection('Aliases', '🏷️')
        self.p('VirtualOS ships with useful pre-defined aliases:')
        alias_data = [
            [Paragraph('Alias', self.styles['TableHeader']),
             Paragraph('Expands To', self.styles['TableHeader']),
             Paragraph('Description', self.styles['TableHeader'])],
        ]
        default_aliases = [
            ('ll', 'ls -la', 'Long listing of all files'),
            ('la', 'ls -a', 'List including hidden files'),
            ('..', 'cd ..', 'Go up one directory level'),
            ('...', 'cd ../..', 'Go up two directory levels'),
            ('cls', 'clear', 'Clear terminal screen'),
            ('q', 'exit', 'Quit VirtualOS session'),
            ('h', 'history', 'Show command history'),
        ]
        for alias, expand, desc in default_aliases:
            alias_data.append([
                Paragraph(alias, self.styles['TableCellCode']),
                Paragraph(expand, self.styles['TableCellCode']),
                Paragraph(desc, self.styles['TableCell']),
            ])
        self.table(alias_data, [self.W*0.15, self.W*0.30, self.W*0.55])

        self.terminal([
            '# View all aliases',
            '$ alias',
            "alias ll='ls -la'",
            "alias la='ls -a'",
            "alias ..='cd ..'",
            '',
            '# Create a custom alias',
            "$ alias update='apt update && apt upgrade'",
            '$ update',
            'Reading package lists... Done',
            '',
            '# Remove an alias',
            '$ unalias update',
        ], 'Aliases Demo')

        self.subsection('Environment Variables', '🌍')
        env_data = [
            [Paragraph('Variable', self.styles['TableHeader']),
             Paragraph('Default Value', self.styles['TableHeader']),
             Paragraph('Description', self.styles['TableHeader'])],
        ]
        env_vars = [
            ('PATH', '/usr/bin:/usr/sbin:/bin:/sbin', 'Command search path'),
            ('HOME', '/home/user', 'Current user home directory'),
            ('USER', 'user', 'Current username'),
            ('SHELL', '/bin/vsh', 'Current shell executable'),
            ('TERM', 'xterm-256color', 'Terminal type'),
            ('LANG', 'en_US.UTF-8', 'System language/locale'),
            ('EDITOR', 'vedit', 'Default text editor'),
            ('PS1', r'\u@\h:\w\$ ', 'Shell prompt format'),
        ]
        for var, val, desc in env_vars:
            env_data.append([
                Paragraph(var, self.styles['TableCellCode']),
                Paragraph(val, self.styles['TableCellCode']),
                Paragraph(desc, self.styles['TableCell']),
            ])
        self.table(env_data, [self.W*0.18, self.W*0.32, self.W*0.50])
        self.pb()

    # ============================================================
    # SECTION 11 – LOGGING
    # ============================================================
    def build_section11(self):
        self.section(11, 'System Logs & Monitoring')

        self.subsection('Log Files', '📋')
        log_data = [
            [Paragraph('Log File', self.styles['TableHeader']),
             Paragraph('Virtual Path', self.styles['TableHeader']),
             Paragraph('Contents', self.styles['TableHeader'])],
            [Paragraph('syslog', self.styles['TableCellCode']),
             Paragraph('/var/log/syslog', self.styles['TableCellCode']),
             Paragraph('General system events: file operations, commands, '
                       'service changes', self.styles['TableCell'])],
            [Paragraph('auth.log', self.styles['TableCellCode']),
             Paragraph('/var/log/auth.log', self.styles['TableCellCode']),
             Paragraph('Authentication events: login attempts, su, sudo, '
                       'passwd changes', self.styles['TableCell'])],
            [Paragraph('kern.log', self.styles['TableCellCode']),
             Paragraph('/var/log/kern.log', self.styles['TableCellCode']),
             Paragraph('Kernel messages and boot events',
                       self.styles['TableCell'])],
        ]
        self.table(log_data, [self.W*0.15, self.W*0.25, self.W*0.60])

        self.subsection('Monitoring Commands', '📊')
        self.cmd_ref([
            ('journalctl', 'journalctl [-n N] [-u unit]',
             'View systemd journal logs with filtering'),
            ('dmesg', 'dmesg', 'Display kernel ring buffer messages'),
            ('top', 'top', 'Real-time process and resource monitor'),
            ('ps', 'ps [aux]', 'Snapshot of current process table'),
            ('free', 'free [-h]', 'Display RAM and swap usage'),
            ('uptime', 'uptime', 'System uptime, users, load average'),
            ('df', 'df [-h]', 'Filesystem disk usage statistics'),
            ('du', 'du [-sh] [dir]', 'Directory disk usage'),
        ])

        self.terminal([
            '$ journalctl -n 10',
            '-- VirtualOS System Journal --',
            '',
            '[2024-01-15 10:30:00] System initialized',
            '[2024-01-15 10:30:01] Kernel boot complete',
            '[2024-01-15 10:30:05] User user logged in',
            '[2024-01-15 10:31:22] mkdir: created directory projects',
            '[2024-01-15 10:32:00] apt: installed python3 3.11.0',
            '[2024-01-15 10:35:00] service: started nginx',
            '',
            '$ cat /var/log/auth.log',
            '[2024-01-15 10:30:05] User user logged in',
            '[2024-01-15 10:34:00] sudo: user executed apt install as root',
        ], 'Log Viewer Demo')
        self.pb()

    # ============================================================
    # SECTION 12 – CONFIGURATION
    # ============================================================
    def build_section12(self):
        self.section(12, 'Configuration & Customization')

        self.subsection('Changing Credentials', '🔑')
        self.p(
            'To modify default login credentials, edit the '
            '<font name="Courier-Bold">init_system_files()</font> function '
            'in <font name="Courier-Bold">virtualos.sh</font> and update '
            'the <font name="Courier-Bold">cmd_su()</font> and '
            '<font name="Courier-Bold">cmd_sudo()</font> functions to match.',
            'BodyJustify')

        self.terminal([
            '# In init_system_files() — users.db section:',
            'cat > "$VETC/security/users.db" << \'USERS\'',
            'root:MY_NEW_ROOT_PASSWORD:0',
            'user:MY_NEW_USER_PASSWORD:1000',
            'USERS',
            '',
            '# In cmd_su() — root login check:',
            'if [ "$password" == "MY_NEW_ROOT_PASSWORD" ]; then',
            '',
            '# In cmd_sudo() — sudo authentication:',
            'if [ "$password" == "MY_NEW_USER_PASSWORD" ]; then',
        ], 'Credential Configuration')

        self.subsection('Adding Custom Packages', '📦')
        self.terminal([
            '# In init_system_files() — available.db section:',
            'cat > "$VVAR/packages/available.db" << \'AVAIL\'',
            '# Format: name|version|description',
            'mypackage|2.0.0|My custom virtual package',
            'anotherpkg|1.5.0|Another custom package',
            'AVAIL',
        ], 'Custom Package Configuration')

        self.subsection('Adding Custom Services', '🔧')
        self.terminal([
            '# In SERVICES declaration at top of script:',
            'declare -A SERVICES',
            'SERVICES[sshd]="running"',
            'SERVICES[myservice]="stopped"   # Add your service',
            '',
            '# Then control it:',
            '$ service myservice start',
            '$ service myservice status',
        ], 'Custom Service Configuration')

        self.subsection('Custom Aliases & Environment', '🏷️')
        self.terminal([
            '# In ALIASES declaration:',
            'declare -A ALIASES',
            'ALIASES[myalias]="my custom command --with-flags"',
            'ALIASES[gs]="git status"',
            '',
            '# In VENV declaration:',
            'declare -A VENV',
            'VENV[MY_VARIABLE]="my_value"',
            'VENV[EDITOR]="vedit"',
        ], 'Aliases & Environment')
        self.pb()

    # ============================================================
    # SECTION 13 – TROUBLESHOOTING
    # ============================================================
    def build_section13(self):
        self.section(13, 'Troubleshooting')

        self.subsection('Common Issues & Solutions', '🔧')
        issues = [
            ('VirtualOS won\'t start',
             'Ensure Bash 4+ is installed. Run: bash --version\n'
             'Fix: pkg install bash',
             'Warning'),
            ('Permission denied errors',
             'You need root for this operation.\n'
             'Use: su (pwd: toor) or sudo <cmd> (pwd: password)',
             'Tip'),
            ('Command not found',
             'Check spelling and use the help command.\n'
             'Type: help | grep <keyword>',
             'Note'),
            ('Filesystem corrupted / broken behavior',
             'Factory reset: ./virtualos.sh --reset\n'
             'Warning: this deletes all virtual files!',
             'Warning'),
            ('Screen display issues / garbled output',
             'Clear terminal: clear or reset\n'
             'Restart: exit && ./virtualos.sh --no-boot',
             'Note'),
            ('cd: no such file or directory',
             'Use absolute paths: /home/user/folder\n'
             'Or check with: ls and pwd',
             'Tip'),
        ]
        for title, solution, kind in issues:
            self.note(f'{title}: {solution}', kind)

        self.subsection('Reset & Recovery', '🔄')
        self.terminal([
            '# Option 1: Built-in reset command',
            '$ ./virtualos.sh --reset',
            'Resetting VirtualOS...',
            'Done. Run again to start fresh.',
            '',
            '# Option 2: Manual reset',
            '$ rm -rf ~/.virtualos',
            '$ ./virtualos.sh',
            '',
            '# Option 3: Selective reset',
            '$ rm -rf ~/.virtualos/root/tmp/*',
            '$ rm ~/.virtualos/.vhistory',
        ], 'Reset & Recovery')

        self.subsection('Performance Tips', '⚡')
        tips = [
            'Use <font name="Courier-Bold">--no-boot</font> flag to skip '
            'the boot animation for faster startup',
            'Use <font name="Courier-Bold">--no-login</font> to bypass '
            'the authentication screen during development',
            'Clear temporary files periodically: '
            '<font name="Courier-Bold">rm -rf /tmp/*</font>',
            'Clear command history to reduce memory: '
            '<font name="Courier-Bold">rm ~/.virtualos/.vhistory</font>',
            'Use <font name="Courier-Bold">kill</font> to terminate '
            'unneeded background processes',
            'Combine both flags for maximum startup speed: '
            '<font name="Courier-Bold">./virtualos.sh --no-boot --no-login</font>',
        ]
        for tip in tips:
            self.bullet(tip)
        self.pb()

    # ============================================================
    # SECTION 14 – CHANGELOG & LICENSE
    # ============================================================
    def build_section14(self):
        self.section(14, 'Changelog & License')

        self.subsection('Version History', '📅')
        ch_data = [
            [Paragraph('Version', self.styles['TableHeader']),
             Paragraph('Date', self.styles['TableHeader']),
             Paragraph('Changes', self.styles['TableHeader'])],
            [Paragraph('v1.0.0', self.styles['TableCellCode']),
             Paragraph('2024-01-15', self.styles['TableCellCenter']),
             Paragraph(
                 '• Initial release\n'
                 '• 100+ built-in commands\n'
                 '• Complete filesystem hierarchy (FHS compliant)\n'
                 '• Multi-user authentication system\n'
                 '• APT package manager with 20+ packages\n'
                 '• Service manager with systemctl interface\n'
                 '• Built-in VEdit text editor\n'
                 '• Network simulation (ping, ifconfig, ip, curl)\n'
                 '• Real-time top process viewer\n'
                 '• System logging (syslog, auth.log, kern.log)\n'
                 '• Boot sequence with animated ASCII art\n'
                 '• Output redirection, piping, command chaining\n'
                 '• Aliases, history, environment variables\n'
                 '• Neofetch system info display\n'
                 '• Shutdown/reboot simulation',
                 self.styles['TableCell'])],
        ]
        self.table(ch_data, [self.W*0.13, self.W*0.17, self.W*0.70])

        self.subsection('MIT License', '📄')
        self.sp(0.1)
        license_lines = [
            'MIT License',
            '',
            'Copyright (c) 2024 VirtualOS Project Contributors',
            '',
            'Permission is hereby granted, free of charge, to any person',
            'obtaining a copy of this software and associated documentation',
            'files (the "Software"), to deal in the Software without',
            'restriction, including without limitation the rights to use,',
            'copy, modify, merge, publish, distribute, sublicense, and/or',
            'sell copies of the Software, and to permit persons to whom the',
            'Software is furnished to do so, subject to the following',
            'conditions:',
            '',
            'The above copyright notice and this permission notice shall be',
            'included in all copies or substantial portions of the Software.',
            '',
            'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,',
            'EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES',
            'OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND',
            'NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT',
            'HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,',
            'WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING',
            'FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR',
            'OTHER DEALINGS IN THE SOFTWARE.',
        ]
        self.terminal(license_lines, 'MIT License')
        self.sp(0.3)
        self.hr(COLOR_HIGHLIGHT, 2)
        self.sp(0.2)
        self.p(
            '<b>VirtualOS</b> — Built with ❤️ for the Termux community.<br/>'
            'A complete virtual operating system experience in a single Bash file.',
            'PageSubtitle')

    # ============================================================
    # MAIN BUILD ENTRY
    # ============================================================
    def build(self):
        print('🚀 Building VirtualOS Documentation PDF...')

        doc = SimpleDocTemplate(
            self.filename,
            pagesize=A4,
            leftMargin=inch,
            rightMargin=inch,
            topMargin=inch * 0.7,
            bottomMargin=inch * 0.7,
            title='VirtualOS Complete Documentation',
            author='VirtualOS Project',
            subject='Virtual Operating System for Termux',
            creator='VirtualOS DocGen v1.0',
        )

        print('  📄 Building cover page...')
        self.build_cover()

        print('  📋 Building table of contents...')
        self.build_toc()

        print('  📖 Section 1: Overview...')
        self.build_section1()

        print('  🚀 Section 2: Installation...')
        self.build_section2()

        print('  🔐 Section 3: Authentication...')
        self.build_section3()

        print('  📁 Section 4: Filesystem...')
        self.build_section4()

        print('  📖 Section 5: Command Reference...')
        self.build_section5()

        print('  📦 Section 6: Package Manager...')
        self.build_section6()

        print('  🔧 Section 7: Service Manager...')
        self.build_section7()

        print('  📝 Section 8: Text Editor...')
        self.build_section8()

        print('  🌐 Section 9: Network...')
        self.build_section9()

        print('  🐚 Section 10: Shell Features...')
        self.build_section10()

        print('  📊 Section 11: Logging...')
        self.build_section11()

        print('  ⚙️  Section 12: Configuration...')
        self.build_section12()

        print('  🔧 Section 13: Troubleshooting...')
        self.build_section13()

        print('  📜 Section 14: Changelog & License...')
        self.build_section14()

        print('  🖨️  Rendering PDF...')
        doc.build(self.story, canvasmaker=PageNumCanvas)

        size = os.path.getsize(self.filename)
        print(f'\n✅ Documentation generated successfully!')
        print(f'📄 File: {self.filename}')
        print(f'📦 Size: {size / 1024:.1f} KB')
        print(f'📅 Date: {datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")}')


# ============================================================
# ENTRY POINT
# ============================================================
if __name__ == '__main__':
    # Check for reportlab
    try:
        import reportlab
    except ImportError:
        print('❌ reportlab not found.')
        print('Install it with:')
        print('  pip install reportlab')
        print('  pip3 install reportlab')
        sys.exit(1)

    output = sys.argv[1] if len(sys.argv) > 1 else 'VirtualOS_Documentation.pdf'
    VirtualOSDoc(output).build()