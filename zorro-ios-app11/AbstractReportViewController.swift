//
//  AbstractReportViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 13/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit

protocol TriggerTxns {
    func triggerGetTransactions()
}

class AbstractReportViewController : SICobroViewController {
    var observer : NSObjectProtocol?
    
    // Elements
    var sstartDate :String = ""
    var sendDate :String = ""
    
    var startDate : Date?
    var endDate : Date?
    
    var disabled : Bool = false
    var tabName:String = ""
    var content: String = ""
    
    var trigger:TriggerTxns?
    
    var filterAvailableOptions : [AvailableOption]?
    
    var contentLabel: UILabel! {
        didSet {
            contentLabel.textColor = .black
            contentLabel.textAlignment = .center
            contentLabel.font = UIFont.boldSystemFont(ofSize: 25)
            contentLabel.text = content
            view.addSubview(contentLabel)

            contentLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                contentLabel.topAnchor.constraint(equalTo: self.view.topAnchor),
                contentLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor),
                contentLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                contentLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }
    
    convenience init(tabName: String, disabled: Bool = false) {
        self.init()
        self.tabName = tabName
        self.disabled = disabled
    }
    
    /*
     *
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "backgroundTable")
        if(disabled) {
            content = "No disponible por el momento"
            contentLabel = UILabel(frame: CGRect(x: 0, y: view.center.y - 50, width: view.frame.width, height: 50))
            return
        }
    }
    
    /*
     *
     */
    func onFilterDatesChange(newStartDate : String,newEndDate : String) {
        debugPrint("On onFilterDatesChange")
        sstartDate = newStartDate
        sendDate = newEndDate
        if let trigger = trigger {
            trigger.triggerGetTransactions()
        }
    }
}


/*
 *
 */
class GenericReportViewController<T,K>: AbstractReportViewController, ReportGenerator, TriggerTxns,
                                         PopUpDelegate,
                                         UITableViewDataSourcePrefetching,
                                         UITableViewDataSource {
    typealias F = T
    typealias P = K
                                        
    let PAGE_SIZE = 10
    
    // UI Views
    var reportsTable:UITableView!
    var fixedheaderView:UIView!
    var safeArea: UILayoutGuide!
    var indicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    var infoContent:UIView!
    var numRecordsLabel:UILabel!
    var filterIcon:BadgedIconButton!
    var innerMessage:UILabel!
    
    var totalPages = 0
    var isLoading = false
    var isLastPage = false
    var totalElements = 0
    var npage = 0
    var elements:[T] = []
    
    var filterStatus : AvailableOption?
    var filterDirection : DirectionEnum?
    
    var itemHeight:CGFloat = 0
    
    let SOURCE_DATE_FORMAT = "dd/MM/yy"
    var SDF:DateFormatter = DateFormatter() {
        didSet {
            SDF.dateFormat = SOURCE_DATE_FORMAT
        }
    }
    
    let MODEL_SHOR_DATE_FORMAT = "dd/MM/yy"
    var FORMAT_DATE:DateFormatter = DateFormatter() {
        didSet {
            FORMAT_DATE.dateFormat = MODEL_SHOR_DATE_FORMAT
        }
    }
    
    override func loadView() {
        super.loadView()
        safeArea = view.layoutMarginsGuide
        
        itemHeight = CGFloat(view.frame.height) / CGFloat(PAGE_SIZE * 2)
        
        self.trigger = self
        setupTopInfoView()
        setupTableView()
        setupIndicator()
        
        innerMessage = UILabel()
        innerMessage.isHidden = true
        innerMessage.textAlignment = .center
        innerMessage.font = UIFont.boldSystemFont(ofSize: 18.0)
        view.addSubview(innerMessage)
        innerMessage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            innerMessage.topAnchor.constraint(equalTo: self.view.topAnchor),
            innerMessage.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            innerMessage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            innerMessage.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideTable(true)
        
        reportsTable.prefetchDataSource = self
        //reportsTable.separatorColor = UIColor()
        reportsTable.dataSource = self
        reportsTable.prefetchDataSource = self
        //reportsTable.delegate = self
        
        reportsTable.rowHeight = CGFloat(itemHeight)
        reportsTable.estimatedRowHeight = CGFloat(itemHeight)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        indicatorView.startAnimating()
        reportsTable.isHidden = true
                
        npage = 0
        getTransactions(page: npage)
    }
    
    func setupTopInfoView() {
        infoContent = UIView()
        numRecordsLabel = UILabel()
        filterIcon = BadgedIconButton()
        filterIcon.frame = CGRect(x: view.frame.width/2 - 22, y: view.frame.height/2 - 22, width: 44, height: 44)
        filterIcon.badgeEdgeInsets = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 10)
        filterIcon.setImage(UIImage(named: "filter"), for: .normal)
        filterIcon.addTarget(self, action: #selector(showDialogFilter), for: .touchUpInside)
        filterIcon.translatesAutoresizingMaskIntoConstraints = false
        
        infoContent.frame.size.width = self.view.frame.width
        infoContent?.addSubview(numRecordsLabel!)
        infoContent?.addSubview(filterIcon!)
        infoContent?.backgroundColor = UIColor(named: "backgroundTable")
        
        numRecordsLabel.font = UIFont.systemFont(ofSize: 14.0)
        numRecordsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            numRecordsLabel.leadingAnchor.constraint(equalTo: infoContent.leadingAnchor, constant: 20),
            numRecordsLabel.trailingAnchor.constraint(equalTo: filterIcon.leadingAnchor, constant: 0),
            numRecordsLabel.topAnchor.constraint(equalTo: infoContent.topAnchor),
            numRecordsLabel.bottomAnchor.constraint(equalTo: infoContent.bottomAnchor),
            numRecordsLabel.centerYAnchor.constraint(equalTo: infoContent.centerYAnchor),
            numRecordsLabel.widthAnchor.constraint(equalTo: infoContent.widthAnchor, constant: -80.0)
        ])
        
        //filterIcon.frame.size.width = CGFloat(50.0)
        NSLayoutConstraint.activate([
            filterIcon.leadingAnchor.constraint(equalTo: numRecordsLabel.trailingAnchor, constant: 0),
            filterIcon.trailingAnchor.constraint(equalTo: infoContent.trailingAnchor, constant: -20),
            filterIcon.topAnchor.constraint(equalTo: infoContent.topAnchor),
            filterIcon.bottomAnchor.constraint(equalTo: infoContent.bottomAnchor),
            filterIcon.centerYAnchor.constraint(equalTo: infoContent.centerYAnchor)
        ])
        
        view.addSubview(infoContent)
        infoContent.translatesAutoresizingMaskIntoConstraints = false
        infoContent.frame.size.height = CGFloat(25.0)
        NSLayoutConstraint.activate([
            infoContent.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            infoContent.leftAnchor.constraint(equalTo: view.leftAnchor),
            infoContent.rightAnchor.constraint(equalTo: view.rightAnchor),
            infoContent.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        
        infoContent.isHidden = true
    }
    
    func setupTableView() {
        reportsTable = UITableView(frame: view.bounds, style: UITableView.Style.plain)
        reportsTable.register(ReportRowCellView<T>.self, forCellReuseIdentifier: "reportRowCell")
        reportsTable.backgroundColor = UIColor(named: "backgroundTable")
        
        //Create Fixed Header
        fixedheaderView = UIView()
        let headerCell = reportsTable.dequeueReusableCell(withIdentifier: "reportRowCell") as! ReportRowCellView<T>
        headerCell.configAsHeader(headerTitlesClosure: self.setHeadersTitles)
        headerCell.frame.size.height = itemHeight
        
        fixedheaderView.addSubview(headerCell)
        view.addSubview(fixedheaderView)
        view.addSubview(reportsTable)
        
        headerCell.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerCell.leadingAnchor.constraint(equalTo: fixedheaderView.leadingAnchor),
            headerCell.trailingAnchor.constraint(equalTo: fixedheaderView.trailingAnchor),
            headerCell.topAnchor.constraint(equalTo: fixedheaderView.topAnchor),
            headerCell.bottomAnchor.constraint(equalTo: fixedheaderView.bottomAnchor)
            //headerCell.heightAnchor.constraint(equalToConstant: itemHeight)
        ])
        
        fixedheaderView.translatesAutoresizingMaskIntoConstraints = false
        fixedheaderView.frame.size.height = itemHeight
        NSLayoutConstraint.activate([
            fixedheaderView.topAnchor.constraint(equalTo: infoContent.bottomAnchor),
            fixedheaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            fixedheaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            fixedheaderView.heightAnchor.constraint(equalToConstant: itemHeight),
            fixedheaderView.bottomAnchor.constraint(equalTo: fixedheaderView.topAnchor)
        ])
        
        reportsTable.translatesAutoresizingMaskIntoConstraints = false
        reportsTable.topAnchor.constraint(equalTo: fixedheaderView.bottomAnchor).isActive = true
        //reportsTable.topAnchor.constraint(equalTo: infoContent.bottomAnchor).isActive = true
        reportsTable.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        reportsTable.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        reportsTable.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
    }
    
    func setupIndicator() {
        indicatorView.center = self.view.center
        indicatorView.hidesWhenStopped = true
        view.addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicatorView.topAnchor.constraint(equalTo: self.view.topAnchor),
            indicatorView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            indicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            indicatorView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    func onPossitiveAction(observerId : Notification.Name?, controller : UIViewController?, popup: CustomPopUpViewController) {
        let filterReports:FilterReportsViewController = controller as! FilterReportsViewController
        debugPrint("Selected direction index: \(filterReports.directionWrapper.selectedItemIndex)")
        var nfilters = 0
        if ( filterReports.directionWrapper.selectedItemIndex >= 0 ) {
            filterDirection = DirectionEnum.allCases[filterReports.directionWrapper.selectedItemIndex]
            nfilters += 1
        }
        
        debugPrint("Selected Filter index: \(filterReports.filterWrapper.selectedItemIndex)")
        if ( filterReports.filterWrapper.selectedItemIndex >= 0 ) {
            if let filterAvailableOptions = filterAvailableOptions {
                filterStatus = filterAvailableOptions[filterReports.filterWrapper.selectedItemIndex]
            }
            nfilters += 1
        }
        
        filterIcon.addBadgeToView(badge: (nfilters == 0) ? nil : "\(nfilters)")
        triggerGetTransactions()
        
        popup.dismiss(animated: true)
    }
    
    func onNegativeAction(observerId : Notification.Name?, controller : UIViewController?, popup: CustomPopUpViewController) {
        //
    }
    
    func onCloseAction(observerId : Notification.Name?, controller : UIViewController?, popup: CustomPopUpViewController) {
        debugPrint("Cleaning filters")
        filterStatus = nil
        filterDirection = nil
        filterIcon.addBadgeToView(badge: nil)
        triggerGetTransactions()
    }
    
    /*
     *
     */
    @objc func showDialogFilter() {
        let storyboard = UIStoryboard(name: "CustomPopup" , bundle: nil)
        let popup = storyboard.instantiateInitialViewController() as! CustomPopUpViewController
        popup.customTitle = "Filtros"
        popup.closeButtonText = "Limpiar"
        // Create Controller
        //let filterReports = FilterReportsViewController()
        let filterReports = storyboard.instantiateViewController(withIdentifier: "filtersVC") as! FilterReportsViewController
        filterReports.setDirectionOptions(directionOptions: DirectionEnum.values)
        if let filterAvailableOptions = self.filterAvailableOptions {
            let options:[String] = filterAvailableOptions.map { (it) -> String in
                (it.name ?? "--")
            }
            filterReports.setFilterOptions(filterOptions: options)
            filterReports.filterWrapper.selectedItemIndex = filterAvailableOptions.lastIndex(where: { (it) -> Bool in
                if let filterStatus = self.filterStatus {
                    return filterStatus.key == it.key
                }
                return false
            }) ?? -1
            //filterReports.filterWrapper.selectedItemIndex += 1
        } else {
            getFilterAvailableOptions(callback: filterReports.getCallbackFilterAvailableOptions(controller: self))
        }
        filterReports.directionWrapper.selectedItemIndex = DirectionEnum.allCases.lastIndex(where: { (it) -> Bool in
            if let filterDirection = self.filterDirection {
                return filterDirection == it
            }
            return false
        }) ?? -1
        //filterReports.directionWrapper.selectedItemIndex += 1
        
        
        popup.controller = filterReports
        popup.positiveButtonLabel = "Aceptar"
        popup.negativeButtonLabel = "Cancelar"
        //popup.fixedHeightSizePer = 0.60
        popup.popUpDelegate = self
        self.present(popup, animated: true)
    }
    
    func buildPageableRequest(page : Int) -> PageableRequest{
        let pageableRequest = PageableRequest()
        pageableRequest.startDate = startDate ?? Date()
        pageableRequest.endDate = endDate ?? Date()
        pageableRequest.page = page
        pageableRequest.pageSize = PAGE_SIZE
        
        if let filterDirection = filterDirection {
            pageableRequest.direction = filterDirection
        }
        if let filterStatus = filterStatus {
            pageableRequest.status = filterStatus.key
        }
        return pageableRequest
    }
    
    /**
     * Initial retrieve of records
     */
    func triggerGetTransactions() {
        debugPrint("On triggerGetTransactions")
        if(!self.validateSessions(forwardToInitial: false, destroyCurrentView: true)) {
            return
        }
        
        refreshItems()
        infoContent.isHidden = true
        hideTable(true)
        indicatorView.isHidden = false
        innerMessage.isHidden = true
        indicatorView.startAnimating()
        npage = 0
        getTransactions(page: npage)
    }
    
    /*
     *
     */
    private func refreshItems() {
        self.elements.removeAll()
        self.reportsTable.reloadData()
    }
    
    /**
     * Asyncrhonous
     */
    private func getTransactions(page : Int) {
        //isLoading = true
        setDates()
        invokeRestForTxns(pageableRequest: buildPageableRequest(page: page))
    }
    
    /**
     *
     */
    private func setDates() {
        print("sstartDate: \(sstartDate)")
        print("sendDate: \(sendDate)")
        SDF.dateFormat = SOURCE_DATE_FORMAT
        startDate = SDF.date(from: sstartDate)
        endDate = SDF.date(from: sendDate)
        
        print("startDate: \(String(describing: startDate))")
        print("endDate: \(String(describing: endDate))")
    }
    
    /*
     *
     */
    func calculateIndexPathsToReload(from newRecords: [T]) -> [IndexPath] {
        let startIndex = elements.count - newRecords.count
        let endIndex = startIndex + newRecords.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    /*
     *
     */
    func onFetchCompleted(totalElementsInPager : Int, isError: Bool, msg:String?) {
        indicatorView.stopAnimating()
        isLoading = false
        reportsTable.reloadData()
        
        if isError {
            var smsg = "Ocurrio un error obteniendo los registros."
            if (msg != nil) {
                smsg = "\(smsg) \(String(describing: msg))"
            }
            innerMessage.text = smsg
            innerMessage.isHidden = false
            infoContent.isHidden = true
            hideTable(true)
            return
        }
        
        infoContent.isHidden = false
        if (totalElementsInPager == 0) {
            numRecordsLabel.isHidden = true     // Show only the filter icon
            hideTable(true)
            innerMessage.text = "No hay registros"
            innerMessage.isHidden = false
            return
        }
        innerMessage.isHidden = true
        updateTotalRecords(total: totalElementsInPager)
        hideTable(false)
    }
    
    func hideTable(_ hide:Bool) {
        reportsTable.isHidden = hide
        fixedheaderView.isHidden = hide
    }

    
    private func updateTotalRecords(total : Int) {
        numRecordsLabel.text = (total == 1) ? "1 Resultado encontrado" : "\(total) Resultados encontrados"
        numRecordsLabel.isHidden = false
    }


    @objc func showDetailItem(sender: DetailTapGestureRecognizer) {
        showDetail(element: elements[sender.indexRow])
    }
    
    private func showDetail(element: T?) {
        let storyboard = UIStoryboard(name: "CustomPopup" , bundle: nil)
        let popup = storyboard.instantiateInitialViewController() as! CustomPopUpViewController
        
        // Set Title
        popup.customTitle = getDetailTitle()
        
        // Create Controller
        let detail = DetailRecordViewController()
        detail.estimatedRowSize = getEstimatedRowSize()
        detail.summaryValues = prepareDetailItem(item: element)
        debugPrint("summaryValues coount: \(detail.summaryValues!.count)")
        
        popup.fixedHeightSizePer = 0.40
        popup.controller = detail
        self.present(popup, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(itemHeight)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(itemHeight)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalElements
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportRowCell", for: indexPath) as! ReportRowCellView<T>

        if isLoadingCell(for: indexPath) {
            cell.configLoadingState()
        } else {
            let element = elements[indexPath.row]
            cell.configElemtn(element: element, generatorClosure: self.configureCell)
            
            let tap = DetailTapGestureRecognizer(target: self, action: #selector(showDetailItem(sender:)))
            tap.indexRow = indexPath.row
            cell.tag = indexPath.row
            cell.addGestureRecognizer(tap)
            cell.isUserInteractionEnabled = true
        }
        cell.backgroundColor = ( indexPath.row % 2 != 0 ) ?
            UIColor(named: "colorTableRowEven") :
            UIColor(named: "colorTableRowOdd")
        return cell
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        print("on prefetchRowsAt")
        print("indexPaths [\(indexPaths)]")
        if indexPaths.contains(where: isLoadingCell) {
            if (!self.isLoading && !self.isLastPage) {
                DispatchQueue.background(delay: 1.0, completion:{
                    self.isLoading = true
                    self.npage += 1
                    self.getTransactions(page: self.npage)
                })
            }
        }
    }
    
    // MARK: Zombie methods to be overrided
    func getFilterAvailableOptions(callback: RestCallback<[AvailableOption]>) {}
    func invokeRestForTxns(pageableRequest: PageableRequest) {}
    func getCallbackPageable(currentPage: Int) -> RestCallback<K>? {return nil}
    func configureCell(cell: ReportRowCellView<T>, element: T){}
    //func showDetail(item : T?){}
    func prepareDetailItem(item : T?) -> [SummaryItem]{return []}
    func getDetailTitle() -> String{return ""}
    func getEstimatedRowSize() -> CGFloat {return 17.0}
    func setHeadersTitles(cell: ReportRowCellView<T>){}
    func getSectionType() -> FragmentSection {FragmentSection.NONE}

}

private extension GenericReportViewController {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= elements.count
    }

    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = reportsTable.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
}

class ReportRowCellView<T> : UITableViewCell {
    let indicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    
    let label1 : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.5
        return lbl
    }()
    
    let label2 : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.5
        return lbl
    }()
    
    let label3 : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.5
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(label1)
        addSubview(label2)
        addSubview(label3)
        
        indicatorView.center = center
        indicatorView.hidesWhenStopped = true
        addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicatorView.topAnchor.constraint(equalTo: topAnchor),
            indicatorView.widthAnchor.constraint(equalTo: widthAnchor),
            indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicatorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        let widthValue = frame.size.width / 3.0
        
        label1.translatesAutoresizingMaskIntoConstraints = false
        label1.frame.size.width = widthValue
        label1.textAlignment = .center
        NSLayoutConstraint.activate([
            label1.topAnchor.constraint(equalTo: topAnchor),
            label1.leadingAnchor.constraint(equalTo: leadingAnchor),
            label1.bottomAnchor.constraint(equalTo: bottomAnchor),
            label1.heightAnchor.constraint(equalTo: heightAnchor),
            //label1.widthAnchor.constraint(equalToConstant: widthValue),
            label1.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.33),
            label1.centerYAnchor.constraint(equalTo: centerYAnchor),
            //label1.centerXAnchor.constraint(equalTo: centerXAnchor),
            //label1.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.frame.size.width = widthValue
        label2.textAlignment = .center
        NSLayoutConstraint.activate([
            label2.topAnchor.constraint(equalTo: topAnchor),
            label2.leadingAnchor.constraint(equalTo: label1.trailingAnchor),
            label2.bottomAnchor.constraint(equalTo: bottomAnchor),
            label2.heightAnchor.constraint(equalTo: heightAnchor),
            //label2.widthAnchor.constraint(equalToConstant: widthValue),
            label2.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.33),
            label2.centerYAnchor.constraint(equalTo: centerYAnchor),
            //label1.centerXAnchor.constraint(equalTo: centerXAnchor),
            //label1.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        label3.translatesAutoresizingMaskIntoConstraints = false
        label3.frame.size.width = widthValue
        label3.textAlignment = .center
        NSLayoutConstraint.activate([
            label3.topAnchor.constraint(equalTo: topAnchor),
            label3.leadingAnchor.constraint(equalTo: label2.trailingAnchor),
            label3.trailingAnchor.constraint(equalTo: trailingAnchor),
            label3.bottomAnchor.constraint(equalTo: bottomAnchor),
            label3.heightAnchor.constraint(equalTo: heightAnchor),
            //label3.widthAnchor.constraint(equalToConstant: widthValue),
            label3.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.33),
            label3.centerYAnchor.constraint(equalTo: centerYAnchor),
            //label1.centerXAnchor.constraint(equalTo: centerXAnchor),
            //label1.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configElemtn(element:T, generatorClosure: (ReportRowCellView,T)->() ) {
        generatorClosure(self, element)
        label1.alpha = 1
        label2.alpha = 1
        label3.alpha = 1
        indicatorView.stopAnimating()
    }
    
    func configLoadingState() {
        label1.alpha = 0
        label2.alpha = 0
        label3.alpha = 0
        indicatorView.startAnimating()
    }
    
    func configAsHeader(headerTitlesClosure: (ReportRowCellView)->()) {
        headerTitlesClosure(self)
        self.backgroundColor = UIColor(named: "colorTableRowEven")
        label1.alpha = 1
        label2.alpha = 1
        label3.alpha = 1
        label1.font = UIFont.boldSystemFont(ofSize: 14)
        label2.font = UIFont.boldSystemFont(ofSize: 14)
        label3.font = UIFont.boldSystemFont(ofSize: 14)
        label1.numberOfLines = 0
        label1.adjustsFontSizeToFitWidth = true
        label1.minimumScaleFactor = 0.5
        label2.numberOfLines = 0
        label2.adjustsFontSizeToFitWidth = true
        label2.minimumScaleFactor = 0.5
        label3.numberOfLines = 0
        label3.adjustsFontSizeToFitWidth = true
        label3.minimumScaleFactor = 0.5
        indicatorView.stopAnimating()
    }
}


protocol ReportGenerator {
    associatedtype F
    associatedtype P
    
    /**
     *
     */
    func getFilterAvailableOptions(callback: RestCallback<[AvailableOption]>)

    /**
     *
     */
    func invokeRestForTxns(pageableRequest: PageableRequest)

    /**
     *
     */
    func getCallbackPageable(currentPage: Int) -> RestCallback<P>?

    /**
     *
     */
    func configureCell(cell: ReportRowCellView<F>, element: F)

    /**
     *
     */
    //func showDetail(item : F?)
    
    /**
     *
     */
    func prepareDetailItem(item : F?) -> [SummaryItem]
    
    /**
     *
     */
    func getDetailTitle() -> String
    
    /**
     *
     */
    func getEstimatedRowSize() -> CGFloat

    /**
     *
     */
    func setHeadersTitles(cell: ReportRowCellView<F>)


    /**
     *
     */
    func getSectionType() -> FragmentSection
}

extension DispatchQueue {

    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
}

//  Based on:
//     https://iosrevisited.blogspot.com/2017/11/swift-add-badge-to-uibutton-uibarbutton.html
class BadgedIconButton : UIButton {
    var badgeLabel = UILabel()
    
    var badge: String? {
        didSet {
            addBadgeToView(badge: badge)
        }
    }

    public var badgeBackgroundColor = UIColor(named: "colorPrimaryDark") {
        didSet {
            badgeLabel.backgroundColor = badgeBackgroundColor
        }
    }
    
    public var badgeTextColor = UIColor(named: "colorPrimary") {
        didSet {
            badgeLabel.textColor = badgeTextColor
        }
    }
    
    public var badgeFont = UIFont.systemFont(ofSize: 12.0) {
        didSet {
            badgeLabel.font = badgeFont
        }
    }
    
    public var badgeEdgeInsets: UIEdgeInsets? {
        didSet {
            addBadgeToView(badge: badge)
        }
    }
    
    var initialized:Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addBadgeToView(badge: nil)
    }
    
    func addBadgeToView(badge: String?) {
        badgeLabel.text = badge
        badgeLabel.textColor = badgeTextColor
        badgeLabel.backgroundColor = badgeBackgroundColor
        badgeLabel.font = badgeFont
        badgeLabel.sizeToFit()
        badgeLabel.textAlignment = .center
        
        //if(!initialized) {
            let badgeSize = badgeLabel.frame.size
            
            let height = max(18, Double(badgeSize.height) + 5.0)
            let width = max(height, Double(badgeSize.width) + 10.0)
            
            var vertical: Double?, horizontal: Double?
            if let badgeInset = self.badgeEdgeInsets {
                vertical = Double(badgeInset.top) - Double(badgeInset.bottom)
                horizontal = Double(badgeInset.left) - Double(badgeInset.right)
                
                let x = (Double(bounds.size.width) - 10 + horizontal!)
                let y = -(Double(badgeSize.height) / 2) - 10 + vertical!
                badgeLabel.frame = CGRect(x: x, y: y, width: width, height: height)
            } else {
                let x = self.frame.width - CGFloat((width / 2.0))
                let y = CGFloat(-(height / 2.0))
                badgeLabel.frame = CGRect(x: x, y: y, width: CGFloat(width), height: CGFloat(height))
            }
            
            badgeLabel.layer.cornerRadius = badgeLabel.frame.height/2
            badgeLabel.layer.masksToBounds = true
            addSubview(badgeLabel)
        //    initialized = true
        //}
        badgeLabel.isHidden = badge != nil ? false : true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addBadgeToView(badge: nil)
        fatalError("init(coder:) has not been implemented")
    }
}

class DetailTapGestureRecognizer: UITapGestureRecognizer {
    var indexRow: Int = 0
}
