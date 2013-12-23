<script language="JavaScript">
<!--
function UpdateClock() {
  var date = new Date();
  document.getElementById('zuluDate').innerHTML = date.toGMTString();
  setTimeout("UpdateClock()", 1000);
}
-->
</script>
<body>
<br>
<table width="100%">
<tr valign="top">
  <td width="25%">
    <table align="left" fgcolor="#c44e4e">
      <tr>
        <td><b>Title</b></td>

      </tr>
      <tr><td>&nbsp;</td></tr>
      <tr>
        <td>
          <b><font size="2"><span id='zuluDate'></span></font></b>
        </td>
      </tr>
      <tr><td>&nbsp;</td></tr>
      <tr>

        <td>
          <a href="./time.html">Time Applet</a>
        </td>
      </tr>
    </table>
  </td>
  <td width="5%">
    <table>
      <tr>
        <td>
          <img src="./images/VeryNarrowVerticalBar.jpg" align="middle">

        </td>
      </tr>
    </table>
  </td>
  <td width="70%">
    <table align="center">
      <tr>
        <td><center>
          <img src="./images/TITLE.png"
            alt=" Title ">

          <br><br><br>
          <!--
          <applet code ="time.ClockApplet" width="200" height="275"
            archive="./Time.jar" alt="ClockApplet:  Java applets must be enabled and plug-in libraries available!">
            <param name=updatePeriod value=1000>
          </applet>
          -->
        </center></td>
      </tr>
    </table>
  </td>
</tr>
</table>
<script language="JavaScript">
<!--
UpdateClock();
-->
</script>

