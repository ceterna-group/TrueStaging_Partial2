.project-status-bar.ClosedWon {
  background: #5FD36C !important
}

.project-status-bar.nodates.ClosedWon {
  background: #f2cf5b !important
}

.project-row.false {
  height: 50px;
}

.project-row .project-details-wrapper {
  height: 49px;
  width: 300px;
  border-bottom: 1px solid #CFD7E6;
  background: #EEF1F6;
  z-index: 10;
  overflow: hidden;
}

.project-row .project-client {
  display: none;
}

.project-row.selected .project-client {
  display: block;
}

.project-row .project-name {
  font-size: 13px;
}

.project-row .project-pm {
  bottom: 5px;
}

.project-row .project-cc {
  bottom: 5px;
  left: 100px;
  width: 90px;
}

.project-row.selected .project-pm {
  bottom: 9px;
}

.project-row.selected .project-cc {
  bottom: 9px;
}

.project-row .project-details {
  padding-left: 15px;
  background: #EEF1F6;
  height: 50px;
  cursor: pointer;
}

.project-row.selected .project-details-wrapper,
.project-row.selected .project-details,
.project-row.selected .project-status-bar {
  height: 410px !important;
}

.project-row.selected {
  height: 410px;
}

.project-row.selected .project-times-wrapper,
.project-row.selected .ghost-times-wrapper {
  height: 356px !important;
  padding-top: 54px !important;
}

.project-rows-time.false .project-times-wrapper {
  height: 50px;
}

.project-times {
  height: 7px;
  text-indent: -99999px;
}

.project-row .project-lock {
  position: absolute;
  top: 11px;
  right: 62px;
  width: 30px;
  height: 30px;
}

.project-row .project-lock img {
  width: 20px;
  height: 21px;
}

.project-row .project-icons {
  top: 9px;
  right: 5px;
}

.project-row .project-icons svg {
  width: 20px;
}

.project-status-bar {
  height: 50px;
}

.project-amount {
  background: #4F6A92;
  color: #fff;
  position: absolute;
  right: 15px;
  padding: 3px;
  bottom: 9px;
  margin-left: 10px;
  font-size: 12px;
  border-radius: 3px;
}

.time-row-input {
  width: calc(50% - 55px);
}