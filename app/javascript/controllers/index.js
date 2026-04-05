// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import { TramwaySelect } from "@tramway/tramway-select"
import { TableRowPreview } from "@tramway/table-row-preview"
eagerLoadControllersFrom("controllers", application)
application.register('tramway-select', TramwaySelect)
application.register('table-row-preview', TableRowPreview)
