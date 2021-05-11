(window.webpackJsonp=window.webpackJsonp||[]).push([["dashboard"],{"522r":function(t,a,e){"use strict";e.r(a);var s=e("oCYn"),n=function(){var t=this,a=t.$createElement,e=t._self._c||a;return t.projectId?e("div",[e("div",{staticClass:"mb-4 w-25"},[e("app-date-range-picker",{model:{value:t.dateRange,callback:function(a){t.dateRange=a},expression:"dateRange"}})],1),t._v(" "),e("counters-cards",{attrs:{counters:t.counters,"is-loading":t.isLoading}}),t._v(" "),e("div",{staticClass:"small mb-5"},[e("line-chart",{attrs:{"chart-data":t.datacollection,options:t.chartOptions}})],1)],1):t._e()};n._withStripped=!0;e("QWBl"),e("4l63"),e("FZtP");var r=e("vDqi"),o=e.n(r),i=e("wd/R"),l=e.n(i),c=e("H8ri"),d=c.b.reactiveProp,u={extends:c.a,mixins:[d],props:["options"],mounted:function(){this.renderChart(this.chartData,this.options)}},j=e("KHd+"),f=Object(j.a)(u,void 0,void 0,!1,null,null,null);f.options.__file="assets/js/App/Components/Dashboard/LineChart.vue";var p=f.exports,v=function(){var t=this,a=t.$createElement,e=t._self._c||a;return e("div",{staticClass:"card-deck mb-5"},[e("div",{staticClass:"card bg-light text-center"},[e("div",{staticClass:"card-body"},[e("h6",{staticClass:"text-uppercase"},[t._v("Sent")]),t._v(" "),t.isLoading?e("i",{staticClass:"fa fa-spinner fa-spin fa-3x text-muted"}):e("div",[e("h3",{staticClass:"text-muted"},[t._v(t._s(t._f("number")(t.counters.sent)))])])])]),t._v(" "),e("div",{staticClass:"card bg-light text-center"},[e("div",{staticClass:"card-body"},[e("h6",{staticClass:"text-uppercase"},[t._v("Delivered")]),t._v(" "),t.isLoading?e("i",{staticClass:"fa fa-spinner fa-spin fa-3x text-muted"}):e("div",[e("h4",{staticClass:"text-success mb-0"},[t._v(t._s(t._f("number")(t.counters.delivered)))]),t._v(" "),e("div",{staticClass:"text-muted"},[t._v(t._s(t._f("number")(t.deliveredProc))+"%")])])])]),t._v(" "),e("div",{staticClass:"card bg-light text-center"},[e("div",{staticClass:"card-body"},[e("h6",{staticClass:"text-uppercase"},[t._v("Opens")]),t._v(" "),t.isLoading?e("i",{staticClass:"fa fa-spinner fa-spin fa-3x text-muted"}):e("h4",{staticClass:"text-primary"},[t._v(t._s(t._f("number")(t.counters.opens)))])])]),t._v(" "),e("div",{staticClass:"card bg-light text-center"},[e("div",{staticClass:"card-body"},[e("h6",{staticClass:"text-uppercase"},[t._v("Clicks")]),t._v(" "),t.isLoading?e("i",{staticClass:"fa fa-spinner fa-spin fa-3x text-muted"}):e("h4",{staticClass:"text-warning"},[t._v(t._s(t._f("number")(t.counters.clicks)))])])]),t._v(" "),e("div",{staticClass:"card bg-light text-center"},[e("div",{staticClass:"card-body"},[e("h6",{staticClass:"text-uppercase"},[t._v("Not Delivered")]),t._v(" "),t.isLoading?e("i",{staticClass:"fa fa-spinner fa-spin fa-3x text-muted"}):e("div",[e("h4",{staticClass:"text-danger mb-0"},[t._v(t._s(t._f("number")(t.counters.notDelivered)))]),t._v(" "),e("div",{staticClass:"text-muted"},[t._v(t._s(t._f("number")(t.notDeliveredProc))+"%")])])])])])};v._withStripped=!0;var g={name:"counters-cards",props:{isLoading:Boolean,counters:Object},computed:{deliveredProc:function(){return this.counters.sent?this.counters.delivered/this.sent*100:0},notDeliveredProc:function(){return this.counters.sent?this.counters.notDelivered/this.sent*100:0}},filters:{number:function(t){return t?new Intl.NumberFormat([],{maximumFractionDigits:2}).format(t):0}}},h=Object(j.a)(g,v,[],!1,null,null,null);h.options.__file="assets/js/App/CountersCards.vue";var m=h.exports,b={name:"DashboardApp",components:{AppDateRangePicker:e("O9K0").a,CountersCards:m,LineChart:p},data:function(){return{isLoading:!0,projectId:window.dashboardProjectId,dateRange:{startDate:l()().locale(window.navigator.language).startOf("week").utc().toDate(),endDate:l()().locale(window.navigator.language).endOf("week").utc().toDate()},datacollection:{},counters:{},chartOptions:{responsive:!0,maintainAspectRatio:!1,tooltips:{mode:"index",intersect:!1},hover:{mode:"nearest",intersect:!0}},chartColors:{Send:"#6c757d",Delivery:"#28a745",Reject:"#db5b67",Bounce:"#c8c8c8",Complaint:"#dc3545",Failure:"#e59aa2",Open:"#007bff",Click:"#ffc107"}}},filters:{date:function(t){return l()(t).format("MMMM Do YYYY")}},methods:{loadData:function(){var t=this;o.a.get(window.dashboardEndpoint,{params:{projectId:parseInt(this.projectId),dateFrom:l()(this.dateRange.startDate).startOf("day").utc().toDate(),dateTo:l()(this.dateRange.endDate).endOf("day").utc().toDate(),tzOffset:l()().utcOffset()}}).then((function(a){t.isLoading=!1,t.counters=a.data.counters,t.fillChartData(a.data.chartData)})).catch((function(t){t.response?alert(t.response.data.error):alert(t)})).then((function(){}))},fillChartData:function(t){var a=this,e=[];t.datasets.forEach((function(t){var s={label:t.label,data:t.data,backgroundColor:a.chartColors[t.label],borderColor:a.chartColors[t.label],fill:!1};e.push(s)}));var s=[];t.labels.forEach((function(t){s.push(l()(t).format("L"))})),this.datacollection={labels:s,datasets:e}}},computed:{firstDayOfWeek:function(){return l.a.localeData(window.navigator.language).firstDayOfWeek()}},watch:{dateRange:function(){this.loadData()}},mounted:function(){this.projectId&&this.loadData()}},D=Object(j.a)(b,n,[],!1,null,null,null);D.options.__file="assets/js/App/DashboardApp.vue";var w=D.exports;new s.a({el:"#app",render:function(t){return t(w)}})},O9K0:function(t,a,e){"use strict";var s=function(){var t=this,a=t.$createElement,e=t._self._c||a;return e("date-range-picker",{ref:"picker",attrs:{opens:"right",autoApply:!0,ranges:t.ranges,"locale-data":{firstDay:t.firstDayOfWeek}},on:{update:t.update},scopedSlots:t._u([{key:"input",fn:function(a){return[e("i",{staticClass:"fa fa-calendar-alt"}),t._v(" "+t._s(t._f("date")(a.startDate))+" - "+t._s(t._f("date")(a.endDate))+"\n  ")]}}]),model:{value:t.dateRange,callback:function(a){t.dateRange=a},expression:"dateRange"}})};s._withStripped=!0;var n=e("wd/R"),r=e.n(n),o=e("u/Xb"),i=e.n(o),l=(e("U7QD"),{name:"AppDateRangePicker",components:{DateRangePicker:i.a},props:["value"],data:function(){return{dateRange:this.value,ranges:{Today:[r()().locale(window.navigator.language).startOf("day").toDate(),r()().locale(window.navigator.language).endOf("day").toDate()],Yesterday:[r()().locale(window.navigator.language).startOf("day").subtract(1,"days").toDate(),r()().locale(window.navigator.language).endOf("day").subtract(1,"days").toDate()],"This week":[r()().locale(window.navigator.language).startOf("week").toDate(),r()().locale(window.navigator.language).endOf("week").toDate()],"Last week":[r()().locale(window.navigator.language).subtract(1,"weeks").startOf("week").toDate(),r()().locale(window.navigator.language).subtract(1,"weeks").endOf("week").toDate()],"This month":[r()().locale(window.navigator.language).startOf("month").toDate(),r()().locale(window.navigator.language).endOf("month").toDate()],"Last month":[r()().locale(window.navigator.language).subtract(1,"months").startOf("month").toDate(),r()().locale(window.navigator.language).subtract(1,"months").endOf("month").toDate()]}}},filters:{date:function(t){return r()(t).locale(window.navigator.language).format("YYYY-MM-DD")}},computed:{firstDayOfWeek:function(){return r.a.localeData(window.navigator.language).firstDayOfWeek()}},methods:{update:function(){this.$emit("input",{startDate:this.dateRange.startDate,endDate:this.dateRange.endDate})}}}),c=(e("w57e"),e("KHd+")),d=Object(c.a)(l,s,[],!1,null,null,null);d.options.__file="assets/js/App/Components/Common/AppDateRangePicker.vue";a.a=d.exports},RnhZ:function(t,a,e){var s={"./af":"K/tc","./af.js":"K/tc","./ar":"jnO4","./ar-dz":"o1bE","./ar-dz.js":"o1bE","./ar-kw":"Qj4J","./ar-kw.js":"Qj4J","./ar-ly":"HP3h","./ar-ly.js":"HP3h","./ar-ma":"CoRJ","./ar-ma.js":"CoRJ","./ar-sa":"gjCT","./ar-sa.js":"gjCT","./ar-tn":"bYM6","./ar-tn.js":"bYM6","./ar.js":"jnO4","./az":"SFxW","./az.js":"SFxW","./be":"H8ED","./be.js":"H8ED","./bg":"hKrs","./bg.js":"hKrs","./bm":"p/rL","./bm.js":"p/rL","./bn":"kEOa","./bn-bd":"loYQ","./bn-bd.js":"loYQ","./bn.js":"kEOa","./bo":"0mo+","./bo.js":"0mo+","./br":"aIdf","./br.js":"aIdf","./bs":"JVSJ","./bs.js":"JVSJ","./ca":"1xZ4","./ca.js":"1xZ4","./cs":"PA2r","./cs.js":"PA2r","./cv":"A+xa","./cv.js":"A+xa","./cy":"l5ep","./cy.js":"l5ep","./da":"DxQv","./da.js":"DxQv","./de":"tGlX","./de-at":"s+uk","./de-at.js":"s+uk","./de-ch":"u3GI","./de-ch.js":"u3GI","./de.js":"tGlX","./dv":"WYrj","./dv.js":"WYrj","./el":"jUeY","./el.js":"jUeY","./en-au":"Dmvi","./en-au.js":"Dmvi","./en-ca":"OIYi","./en-ca.js":"OIYi","./en-gb":"Oaa7","./en-gb.js":"Oaa7","./en-ie":"4dOw","./en-ie.js":"4dOw","./en-il":"czMo","./en-il.js":"czMo","./en-in":"7C5Q","./en-in.js":"7C5Q","./en-nz":"b1Dy","./en-nz.js":"b1Dy","./en-sg":"t+mt","./en-sg.js":"t+mt","./eo":"Zduo","./eo.js":"Zduo","./es":"iYuL","./es-do":"CjzT","./es-do.js":"CjzT","./es-mx":"tbfe","./es-mx.js":"tbfe","./es-us":"Vclq","./es-us.js":"Vclq","./es.js":"iYuL","./et":"7BjC","./et.js":"7BjC","./eu":"D/JM","./eu.js":"D/JM","./fa":"jfSC","./fa.js":"jfSC","./fi":"gekB","./fi.js":"gekB","./fil":"1ppg","./fil.js":"1ppg","./fo":"ByF4","./fo.js":"ByF4","./fr":"nyYc","./fr-ca":"2fjn","./fr-ca.js":"2fjn","./fr-ch":"Dkky","./fr-ch.js":"Dkky","./fr.js":"nyYc","./fy":"cRix","./fy.js":"cRix","./ga":"USCx","./ga.js":"USCx","./gd":"9rRi","./gd.js":"9rRi","./gl":"iEDd","./gl.js":"iEDd","./gom-deva":"qvJo","./gom-deva.js":"qvJo","./gom-latn":"DKr+","./gom-latn.js":"DKr+","./gu":"4MV3","./gu.js":"4MV3","./he":"x6pH","./he.js":"x6pH","./hi":"3E1r","./hi.js":"3E1r","./hr":"S6ln","./hr.js":"S6ln","./hu":"WxRl","./hu.js":"WxRl","./hy-am":"1rYy","./hy-am.js":"1rYy","./id":"UDhR","./id.js":"UDhR","./is":"BVg3","./is.js":"BVg3","./it":"bpih","./it-ch":"bxKX","./it-ch.js":"bxKX","./it.js":"bpih","./ja":"B55N","./ja.js":"B55N","./jv":"tUCv","./jv.js":"tUCv","./ka":"IBtZ","./ka.js":"IBtZ","./kk":"bXm7","./kk.js":"bXm7","./km":"6B0Y","./km.js":"6B0Y","./kn":"PpIw","./kn.js":"PpIw","./ko":"Ivi+","./ko.js":"Ivi+","./ku":"JCF/","./ku.js":"JCF/","./ky":"lgnt","./ky.js":"lgnt","./lb":"RAwQ","./lb.js":"RAwQ","./lo":"sp3z","./lo.js":"sp3z","./lt":"JvlW","./lt.js":"JvlW","./lv":"uXwI","./lv.js":"uXwI","./me":"KTz0","./me.js":"KTz0","./mi":"aIsn","./mi.js":"aIsn","./mk":"aQkU","./mk.js":"aQkU","./ml":"AvvY","./ml.js":"AvvY","./mn":"lYtQ","./mn.js":"lYtQ","./mr":"Ob0Z","./mr.js":"Ob0Z","./ms":"6+QB","./ms-my":"ZAMP","./ms-my.js":"ZAMP","./ms.js":"6+QB","./mt":"G0Uy","./mt.js":"G0Uy","./my":"honF","./my.js":"honF","./nb":"bOMt","./nb.js":"bOMt","./ne":"OjkT","./ne.js":"OjkT","./nl":"+s0g","./nl-be":"2ykv","./nl-be.js":"2ykv","./nl.js":"+s0g","./nn":"uEye","./nn.js":"uEye","./oc-lnc":"Fnuy","./oc-lnc.js":"Fnuy","./pa-in":"8/+R","./pa-in.js":"8/+R","./pl":"jVdC","./pl.js":"jVdC","./pt":"8mBD","./pt-br":"0tRk","./pt-br.js":"0tRk","./pt.js":"8mBD","./ro":"lyxo","./ro.js":"lyxo","./ru":"lXzo","./ru.js":"lXzo","./sd":"Z4QM","./sd.js":"Z4QM","./se":"//9w","./se.js":"//9w","./si":"7aV9","./si.js":"7aV9","./sk":"e+ae","./sk.js":"e+ae","./sl":"gVVK","./sl.js":"gVVK","./sq":"yPMs","./sq.js":"yPMs","./sr":"zx6S","./sr-cyrl":"E+lV","./sr-cyrl.js":"E+lV","./sr.js":"zx6S","./ss":"Ur1D","./ss.js":"Ur1D","./sv":"X709","./sv.js":"X709","./sw":"dNwA","./sw.js":"dNwA","./ta":"PeUW","./ta.js":"PeUW","./te":"XLvN","./te.js":"XLvN","./tet":"V2x9","./tet.js":"V2x9","./tg":"Oxv6","./tg.js":"Oxv6","./th":"EOgW","./th.js":"EOgW","./tk":"Wv91","./tk.js":"Wv91","./tl-ph":"Dzi0","./tl-ph.js":"Dzi0","./tlh":"z3Vd","./tlh.js":"z3Vd","./tr":"DoHr","./tr.js":"DoHr","./tzl":"z1FC","./tzl.js":"z1FC","./tzm":"wQk9","./tzm-latn":"tT3J","./tzm-latn.js":"tT3J","./tzm.js":"wQk9","./ug-cn":"YRex","./ug-cn.js":"YRex","./uk":"raLr","./uk.js":"raLr","./ur":"UpQW","./ur.js":"UpQW","./uz":"Loxo","./uz-latn":"AQ68","./uz-latn.js":"AQ68","./uz.js":"Loxo","./vi":"KSF8","./vi.js":"KSF8","./x-pseudo":"/X5v","./x-pseudo.js":"/X5v","./yo":"fzPg","./yo.js":"fzPg","./zh-cn":"XDpg","./zh-cn.js":"XDpg","./zh-hk":"SatO","./zh-hk.js":"SatO","./zh-mo":"OmwH","./zh-mo.js":"OmwH","./zh-tw":"kOpN","./zh-tw.js":"kOpN"};function n(t){var a=r(t);return e(a)}function r(t){if(!e.o(s,t)){var a=new Error("Cannot find module '"+t+"'");throw a.code="MODULE_NOT_FOUND",a}return s[t]}n.keys=function(){return Object.keys(s)},n.resolve=r,t.exports=n,n.id="RnhZ"},Yyb4:function(t,a,e){},w57e:function(t,a,e){"use strict";e("Yyb4")}},[["522r","runtime",0,2]]]);