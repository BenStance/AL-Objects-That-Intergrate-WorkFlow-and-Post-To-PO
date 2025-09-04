# RGP (Request for Goods Purchase) Workflow Solution for Business Central

A comprehensive purchase request management system with integrated approval workflow and automatic purchase order generation for Microsoft Dynamics 365 Business Central.

## 📋 Overview

This solution provides a complete end-to-end process for managing purchase requests, vendor selection, approval workflows, and automatic purchase order creation within Business Central. It streamlines the procurement process while maintaining full integration with standard Business Central functionality.

## 🚀 Key Features

- **📝 RGP Request Management**: Complete document handling for purchase requests
- **🏢 Multi-Vendor Support**: Compare prices and select from multiple vendors
- **✅ Approval Workflow**: Integrated approval process with status tracking
- **🛒 Auto PO Generation**: Automatic purchase order creation from approved requests
- **⭐ Vendor Acceptance**: Vendor selection and acceptance tracking
- **📊 Real-time Calculations**: Automatic VAT and total amount calculations
- **🔐 Status-based Security**: Editable controls based on document status
- **📋 Dimension Support**: Full dimension integration for financial tracking

## 🏗️ Architecture

### AL Objects Structure

```
📦 RGP-Workflow-Solution
├── 📄 Tables/
│   ├── 50210 RGP Request Header.al
│   ├── 50211 RGP Request Item Line.al
│   └── 50212 RGP Request Vendor Line.al
├── 📄 Pages/
│   ├── 50213 RGP Request Document.al
│   ├── 50210 RGP Request Item Subform.al
│   └── 50211 RGP Request Vendor Subform.al
├── 📄 Codeunits/
│   ├── 50210 RGP Custom Workflow Mgmt.al
│   └── 50211 RGP Request to Purchase Order.al
└── 📄 Enums/
    ├── RGP Status Enum.al
    └── RGP Line Types Enum.al
```

### Data Model
- **RGP Request Header**: Main document with header information and status
- **RGP Request Item Line**: Requested items with quantities and pricing
- **RGP Request Vendor Line**: Vendor proposals and acceptance status

## 🛠️ Installation

### Prerequisites
- Microsoft Dynamics 365 Business Central (On-premises or SaaS)
- Visual Studio Code with AL Language extension
- Git version control system

### Step-by-Step Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/BenStance/AL-Objects-That-Integrate-WorkFlow-and-Post-To-PO.git
   cd AL-Objects-That-Integrate-WorkFlow-and-Post-To-PO
   ```

2. **Open in Visual Studio Code**
   ```bash
   code .
   ```

3. **Build and Publish**
   - Configure your `launch.json` with your Business Central environment details
   - Build the project (Ctrl+Shift+B)
   - Publish the extension to your Business Central environment

4. **Post-Installation Setup**
   ```al
   // Run this code in Business Central to create the workflow
   codeunit 50210."RGP Custom Workflow Mgmt".CreateRGPApprovalWorkflow();
   ```

### Configuration

1. **Number Series Setup**
   - Navigate to: **Purchases & Payables Setup**
   - Set up number series for "RFQ" (Request for Quotation)

2. **Workflow Configuration**
   - Go to: **Approval Workflows**
   - Enable the "RGP Request Approval Workflow"

3. **User Setup**
   - Configure approval users in: **Approval User Setup**

## 📖 Usage Guide

### Creating a New Request

1. **Open RGP Request Document**
   - Search for "RGP Request" in Business Central
   - Click "New" to create a new request

2. **Enter Header Information**
   - Request Date, Type (Purchase/Transfer), Requested By
   - Dimensions, Comments, Expected Date

3. **Add Items**
   - In the Items subform, add required items
   - Specify quantities, units of measure, and locations

4. **Add Vendors**
   - In the Vendors subform, add potential vendors
   - Vendors can be rated and quoted amounts can be recorded

### Approval Process

1. **Send for Approval**
   - Click "Send Approval Request" when request is complete
   - Status changes from **Open** → **Pending**

2. **Approval Actions**
   - Approvers receive notifications in their approval inbox
   - They can approve, reject, or delegate requests

3. **Post-Approval**
   - Status changes to **Approved** after successful approval
   - Document becomes ready for PO generation

### Generating Purchase Orders

1. **Select Accepted Vendor**
   - Mark the chosen vendor as "Accepted" in the vendor subform

2. **Create Purchase Order**
   - Click "Convert to Purchase Order" action
   - System automatically creates PO with all items

3. **Completion**
   - Status changes to **Completed**
   - Purchase order number is recorded against the vendor

## 🔄 Workflow Status Flow

```
Open → Pending → Approved → Completed
```

- **Open**: Document is being prepared and can be edited
- **Pending**: Sent for approval, awaiting review
- **Approved**: Successfully approved, ready for PO creation
- **Completed**: Purchase order has been created

## 🎯 Business Benefits

- **Reduced Processing Time**: Automated workflow reduces manual steps
- **Better Vendor Management**: Multiple vendor comparison capabilities
- **Improved Compliance**: Full audit trail of approvals and changes
- **Cost Control**: Vendor rating and quoted amount tracking
- **Seamless Integration**: Full compatibility with standard Business Central POs

## 🐛 Troubleshooting

### Common Issues

1. **"No approval workflow enabled" error**
   - Solution: Run the `CreateRGPApprovalWorkflow()` function

2. **Number series not configured**
   - Solution: Set up RFQ number series in Purchases & Payables Setup

3. **Vendor not found errors**
   - Solution: Ensure vendors exist in the Vendor table

### Debug Tips

- Check workflow setup in **Approval Workflows** page
- Verify number series configuration
- Ensure users have appropriate permissions



### Development Guidelines

- Follow AL coding standards and best practices
- Include comprehensive comments
- Test thoroughly before submitting PR
- Update documentation for new features

## 📞 Support

For support and questions:

- 📧 Email: 23ycnsale@gmail.com
- 🐛 Issues: GitHub.com

## 📜 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## 🙏 Acknowledgments

- Microsoft Dynamics 365 Business Central team
- AL developer community
- Contributors and testers

---

**Version**: 1.0.0  
**Last Updated**: 2025 
**Compatibility**: Business Central 2022 Wave 2 and later

For more information, please refer to the [documentation](Docs/) folder or create