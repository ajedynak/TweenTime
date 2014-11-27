define (require) ->
  class Selection
    constructor: (@timeline, @linesContainer, @margin) ->
      @init()

    init: () ->
      self = this
      @linesContainer.on("mousedown", () ->
        p = d3.mouse(this)
        self.linesContainer.append('rect')
          .attr({
            rx: 6,
            ry: 6,
            class: 'selection',
            x: p[0],
            y: p[1],
            width: 0,
            height: 0
          })
        # Unselect items.
        self.timeline.selectionManager.reset()
        # Prevent default browser text selection.
        $('body').css({
          'user-select': 'none'
        })
      ).on("mousemove", () ->
        s = self.linesContainer.select('.selection')
        if s.empty() then return
        p = d3.mouse(this)
        margin: self.margin
        d = {
          x: parseInt(s.attr('x'), 10),
          y: parseInt(s.attr('y'), 10),
          width: parseInt(s.attr('width'), 10),
          height: parseInt(s.attr('height'), 10)
        }
        # Apply margin to mouse selection.
        p[0] = Math.max(self.margin.left, p[0])

        move = {
          x: p[0] - d.x,
          y: p[1] - d.y
        }
        if move.x < 1 || move.x * 2 < d.width
          d.x = p[0]
          d.width -= move.x
        else
          d.width = move.x

        if move.y < 1 || move.y * 2 < d.height
          d.y = p[1]
          d.height -= move.y
        else
          d.height = move.y

        s.attr(d)

        # remove margins from selection
        d.x -= self.margin.left
        key_width = 6

        d.timeStart = self.timeline.x.invert(d.x - key_width).getTime() / 1000
        d.timeEnd = self.timeline.x.invert(d.x + d.width + key_width).getTime() / 1000
        containerBounding = self.linesContainer[0][0].getBoundingClientRect()
        console.log containerBounding
        # not sure why there is ~15px difference in y


        # deselect all previously selected items
        d3.selectAll('.key--selected').classed('key--selected', false)
        self.timeline.selectionManager.reset()
        selection = []
        d3.selectAll('.key').each (state_data, i) ->
          itemBounding = d3.select(this)[0][0].getBoundingClientRect()
          y = itemBounding.top - containerBounding.top
          if state_data.time >= d.timeStart && state_data.time <= d.timeEnd
            # use or condition for top and bottom
            if (y >= d.y && y <= d.y + d.height) || (y + 10 >= d.y && y + 10 <= d.y + d.height)
              d3.select(this).classed('key--selected', true)
              #self.timeline.selectionManager.select(this, true)
              selection.push(this)

        self.timeline.selectionManager.select(selection)

      ).on("mouseup", () ->
        self.linesContainer.selectAll('.selection').remove()
        # Enable again the default browser text selection.
        $('body').css({
          'user-select': 'all'
        })
      )